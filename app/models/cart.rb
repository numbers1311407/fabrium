class Cart < ActiveRecord::Base
  include Authority::Abilities

  before_create :generate_public_id

  enum state: [:mill, :buyer, :ordered, :closed]

  scope :state, ->(v) { (n = states[v]) ? where(state: n) : none }
  scope :mill_created, ->(v=true) { v ? where.not(mill_id: nil) : where(mill_id: nil) }
  scope :buyer_created, ->(v=true) { mill_created(!v) }

  has_many :cart_items,
    -> { includes(:fabric_variant).joins(:fabric_variant).order("fabric_variants.fabrium_id ASC") },
    dependent: :destroy

  accepts_nested_attributes_for :cart_items

  has_many :fabric_variants, through: :cart_items

  # Optional, the mill that generated this cart.  This is probably the
  # less common case, whereas the buyer would normally create a cart by
  # visiting the site and adding items.
  belongs_to :mill

  # The buyer for the cart.  This is not optional but may not be populated
  # immediately if this is a mill-generated cart for a buyer email that
  # does not exist.  Upon submitting the cart the buyer will be created.
  belongs_to :buyer

  def to_param
    public_id
  end

  protected

  def generate_public_id
    self.public_id = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(public_id: random_token)
    end
  end
end
