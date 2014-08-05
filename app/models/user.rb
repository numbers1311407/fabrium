require 'validators/email_validator'

class User < ActiveRecord::Base
  include Authority::UserAbilities
  include Authority::Abilities

  include Users::BelongsToMeta

  has_many :favorites
  has_many :favorite_fabric_variants, through: :favorites, source: :fabric_variant

  has_many :fabric_notes

  after_commit :send_invitation_if_admin, on: :create

  before_create :set_initial_pending_status
  after_update :on_pending_change, if: :pending_changed?

  define_meta_types :admin, :mill, :buyer

  devise :database_authenticatable, 
    :invitable, 
    :registerable,
    :recoverable, 
    :trackable, 
    :timeoutable,
    :validatable, 
    :lockable

  validates :email, presence: true, email: true, uniqueness: true

  # don't require password on creation as users are created in the admin
  def password_required?
    super if persisted? || invited_by.blank?
  end

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
