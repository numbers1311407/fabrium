class Cart < ActiveRecord::Base

  include Authority::Abilities
  include HasState

  MILL_NAME_TEMPLATE = "%s Generated Hanger Request %s"
  BUYER_NAME_TEMPLATE = "Hanger Request %s"

  validates :buyer_email, email: true, confirmation: true, if: :transitioning_from_mill_build_to_buyer_unclaimed?
  validate :buyer_email_must_be_blank_or_buyer, if: :transitioning_from_mill_build_to_buyer_unclaimed?
  attr_accessor :buyer_email_confirmation

  validates :cart_items, presence: true, if: :transitioning_from_buyer_build_to_pending?

  before_create :generate_public_id
  after_create :generate_name

  before_save :perform_state_update

  define_states(
    # Mill created, not yet submitted to buyer
    # Mill can edit items or remove cart
    :mill_build,

    # TODO I think we're missing a state here where the buyer hasn't yet
    # claimed the cart.  It's TBD how this happens though:
    #
    # - Does the mill build process CREATE a buyer with the given email?
    # - Is the prospective buyer redirected to create an account when he/she
    #   submits the form?  If that's the case, what if their email is not
    #   accepted and they end up in a pending queue?
    #
    # - I think the latter is probably the case:
    # 1. Buyer follows email to site.
    :buyer_unclaimed,

    # In the hands of the buyer, awaiting edit/submit
    :buyer_build,

    # Submitted, but awaiting change in buyer pending status
    :pending,

    # Submitted, has active items
    :ordered,

    # Submitted, all items resolved
    :closed
  )

  has_many :cart_items, -> { order(fabrium_id: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :cart_items


  # At the order processing stage, sub carts are created if a cart has items
  # within that belong to more than one mill.  This alias will subquery
  # the relevant items from the parent for the mill of this cart
  def cart_items_with_parent
    if parent
      parent.cart_items.where(mill_id: self.mill_id)
    else
      cart_items_without_parent
    end
  end
  alias_method_chain :cart_items, :parent


  def build_subcarts
    # do not build subcarts for subcarts
    return [] if parent.present?

    grouped_items = cart_items.group_by(&:mill_id)

    # stop here if there's only one cart
    return [] if grouped_items.length < 2

    grouped_items.keys.map do |mill_id|
      cart = self.dup
      cart.parent = self
      cart.mill_id = mill_id
      cart
    end
  end


  has_many :fabric_variants, through: :cart_items

  # The cart belongs to a `creator` which may be either a cart or a mill.
  # This distinction is important for authority rules and made clear via this
  # column.  Carts that are not created by a buyer cannot have items added or
  # removed, for example.
  #
  belongs_to :creator, polymorphic: true

  # A Cart, once ordered will be split up into sub carts if it contains cart
  # items for more than one mill.  This greatly simplifies the query logic
  # for the carts resource control, meaning that Mills load only carts belonging
  # to them, instead of having to join on cart items OR carts belonging to them.
  #
  # The buyer on the other hand will only ever load the parent carts and see all
  # cart items together.
  #
  belongs_to :parent, class_name: 'Cart', foreign_key: :parent_id

  # The buyer for the cart may be assigned at 3 stages.
  #
  # 1. The buyer itself creates a cart.  This is the typical case, effected
  # by a buyer user searching for and adding items
  #
  # 2. A mill creates a cart and submits it to a buyer by email, and a buyer
  # by that email EXISTS.  The cart is associated immediately.
  #
  # 3. A mill creates a cart and submits it to a buyer by email, and a buyer
  # by that email DOES NOT EXIST.  The buyer can edit the cart and on submit,
  # will be directed to create an account.
  #
  # In case 2 or 3, if the buyer account is still pending, the cart will
  # be put into a pending state.  When the buyer is activated, any
  # pending orders they have should be put into the `ordered` state.
  #
  belongs_to :buyer

  # The mill for the cart may be assigned at 2 stages.
  #
  # 1. A mill may create a cart, and will be assigned on creation.
  #
  # 2. When a buyer created cart transitions from the pending state 
  # into `ordered`, "child" carts will be created for each mill that is
  # responsible for items in the cart, provided that more than one such 
  # mill exists.  If all the items in the cart belong to a single mill
  # then the cart will simply be assigned to that mill.
  #
  belongs_to :mill

  class << self
    def created_by_buyer(buyer=nil)
      buyer ? where(creator: buyer) : where(creator_type: 'Buyer')
    end

    def created_by_mill(mill=nil)
      mill ? where(creator: mill) : where(creator_type: 'Mill')
    end

    def claim_cart(cart_id, buyer) 
      if cart = state(:buyer_unclaimed).find_by(id: cart_id)
        cart.buyer = buyer
        cart.bump_state
        cart.save
      end
    end
  end

  scope :exclude_subcarts, -> { where(parent_id: nil) }
  scope :subcarts, -> { where.not(parent_id: nil) }

  def mill_created?
    creator_type == 'Mill'
  end

  def buyer_created?
    creator_type == 'Buyer'
  end

  def public?
    buyer.blank?
  end

  def subcart?
    parent_id.present?
  end

  def siblings
    return Cart.none unless subcart?
    scoped = Cart.where(parent_id: parent_id)
    scoped = scoped.where.not(id: id) if persisted?
    scoped
  end

  protected

  def buyer_email_must_be_blank_or_buyer
    # clear the buyer user each validation
    @buyer_user = nil

    if buyer_user && !buyer_user.is_buyer?
      errors.add(:buyer_email, :email_not_buyer)
    end
  end

  def buyer_user
    return nil if buyer_email.blank?
    @buyer_user ||= User.find_by(email: buyer_email)
  end

  #
  # Super basic "state machine" setup to capture transitions.  If 
  # anything more sophisticated becomes necessary I'd probably transition
  # to a plugin.
  #
  def perform_state_update
    return unless state_changed?

    return if @ignore_state_changes

    case state_change
    when %w(mill_build buyer_unclaimed)
      transition_mill_build_to_buyer_unclaimed
    when %w(buyer_unclaimed buyer_build)
      transition_buyer_unclaimed_buyer_build
    when %w(buyer_build pending)
      transition_buyer_build_to_pending
    when %w(pending ordered)
      transition_pending_to_ordered
    when %w(ordered closed)
      transition_ordered_to_closed
    end
  end

  #
  # Mainly for testing, turn off state watching on the instance
  #
  def ignore_state_changes!
    @ignore_state_changes = true
  end

  #
  # Resets the state and re-runs the perform_state_update
  #
  def reset_changed_state new_state
    self.changed_attributes[:state] = self.state
    self.state = new_state
    perform_state_update
  end

  def transition_mill_build_to_buyer_unclaimed
    MailerJob.new.async.perform(AppMailer, :mill_cart_created, self)

    # if there's a buyer user attach them to the cart immediately and
    # re-run the state update
    if buyer_user
      self.buyer = buyer_user.meta
    end

    if buyer.present?
      reset_changed_state :buyer_build
    end
  end

  def transition_buyer_unclaimed_buyer_build
    # nothing to do here
  end

  def transition_buyer_build_to_pending
    # As long as the user is not pending, transition straight
    # out of pending into ordered
    if buyer.respond_to?(:user) && !buyer.user.pending?
      reset_changed_state :ordered
    end
  end

  def transition_pending_to_ordered
    ProcessOrderJob.new.async.perform(:transition_to_ordered, id)
  end

  def transition_ordered_to_closed
    # if this is a subcart and there are no carts in the "open" state,
    # set the parent to closed
    if subcart? && siblings.not_state(:closed).any?
      parent.update(state: :closed)
    end
  end

  def generate_name
    generated_name = if creator_type == "Mill"
      MILL_NAME_TEMPLATE % [creator.name, id]
    else
      BUYER_NAME_TEMPLATE % [id]
    end

    update(name: generated_name)
  end

  def generate_public_id
    self.public_id = loop do
      random_token = SecureRandom.urlsafe_base64(16).tr('lIO0_-', 'sxyzUD')
      break random_token unless self.class.exists?(public_id: random_token)
    end
  end
end
