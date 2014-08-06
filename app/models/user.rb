require 'validators/email_validator'

class User < ActiveRecord::Base
  include Authority::UserAbilities
  include Authority::Abilities

  include Users::BelongsToMeta

  has_many :favorites
  has_many :favorite_fabrics, through: :favorites, source: :fabric

  has_many :fabric_notes
  before_validation :clean_password_fields

  after_commit :send_invitation_if_admin, on: :create

  before_validation :preset_pending_status, on: :create
  before_create :set_initial_pending_status
  after_update :on_pending_change, if: :pending_changed?

  define_meta_types :admin, :mill, :buyer

  devise :database_authenticatable, 
    :invitable, 
    :registerable,
    :recoverable, 
    :trackable, 
    :validatable, 
    :lockable

  validates :email, presence: true, email: true, uniqueness: true

  scope :pending, -> { where(pending: true) }

  def send_invitation!(from)
    InviteUserJob.new.async.perform(id, from.id)
  end

  def domain
    email.match(/@(.*)$/)[1] if email.present?
  end

  def active_for_authentication? 
    !pending? && super
  end 

  def inactive_message 
    pending? && :pending || super
  end

  protected

  def clean_password_fields
    clean_up_passwords if password.blank?
  end

  # as this affects validation
  def preset_pending_status
    self.pending = true if nil == self.pending
  end

  def set_initial_pending_status
    self.pending = if is_buyer?
      !ApprovedDomain.for_buyer.exists?(name: self.domain)
    elsif is_mill?
      !ApprovedDomain.for_mill.exists?(name: self.domain)
    else
      false
    end

    true
  end

  def on_pending_change
    TransitionPendingUserJob.new.async.perform(id) if !pending
  end

  def send_invitation_if_admin
    send_invitation!(self.invited_by) if self.invited_by && is_admin?
  end
end
