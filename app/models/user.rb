require 'validators/email_validator'

class User < ActiveRecord::Base
  include Authority::UserAbilities
  include Authority::Abilities

  devise :database_authenticatable, 
    :invitable, 
    :confirmable,
    :registerable,
    :recoverable, 
    :trackable, 
    :validatable, 
    :lockable

  include Users::BelongsToMeta
  include Users::AdminCreation

  has_many :favorites
  has_many :favorite_fabrics, through: :favorites, source: :fabric

  has_many :fabric_notes

  after_commit :send_invitation_if_invited, on: :create

  before_validation :preset_pending_status, on: :create
  before_create :set_mill_if_mill_passed
  before_create :set_initial_pending_status
  after_update :on_pending_change, if: :pending_changed?

  before_create :set_as_admin_if_attached_to_new_mill

  define_meta_types :admin, :mill, :buyer

  validates :email, presence: true, email: true, uniqueness: true

  # Hack to pass mill in users controller #new
  attr_accessor :mill
  validates :mill, presence: true, on: :create, if: :should_validate_mill?

  scope :pending, ->(val=true) { where(pending: !!val) }

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

  delegate :name, to: :meta, prefix: true, allow_nil: true

  protected

  # as this affects validation
  def preset_pending_status
    self.pending = true if nil == self.pending
  end

  def set_initial_pending_status

    self.pending = 
      # invited users are never pending
      if is_admin? || invited_by.present?
        false
      elsif is_buyer?
        !ApprovedDomain.for_buyer.exists?(name: self.domain)
      elsif is_mill?
        !ApprovedDomain.for_mill.exists?(name: self.domain)
      end

    # If this user is pending, it doesn't need to be later confirmed,
    # as the admin will be confirming them and sending the email that
    # way.
    #
    # If the user is invited, they do not need confirmation.  Only users
    # created through registration should be confirmed.
    if invited_by.present? || pending?
      self.skip_confirmation!
    end

    true
  end

  def on_pending_change
    TransitionPendingUserJob.new.async.perform(id) if !pending

    # If we're the mill's creator, ensure that it is activated along
    # with us.
    if is_mill? && meta.present? && meta.creator == self
      meta.update(active: true)
    end
  end

  def send_invitation_if_invited
    send_invitation!(self.invited_by) if self.invited_by
  end

  def set_as_admin_if_attached_to_new_mill
    if is_mill? && meta.new_record?
      self.admin = true
    end
  end

  def set_mill_if_mill_passed
    if mill
      mill_record = Mill.find_by(id: mill)
      unless mill_record.present?
        errors.add(:mill, "An error occurred assigning the mill.  A mill must be selected.")
        return false
      end

      self.meta = mill_record
    end
  end

  def should_validate_mill?
    !@mill.nil?
  end
end
