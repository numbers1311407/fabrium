class CartItem < ActiveRecord::Base
  include Authority::Abilities
  include HasState

  define_states :pending, :shipped, :refused

  belongs_to :cart
  belongs_to :fabric_variant
  belongs_to :mill

  validates :cart, presence: true
  validates :fabric_variant, presence: true
  validate :ensure_fabric_variant_belongs_to_cart_mill, on: :create

  before_create :denormalize_attrs

  before_save :perform_state_update

  protected

  # It should be impossible to add items from different mills into a
  # cart created by a Mill
  def ensure_fabric_variant_belongs_to_cart_mill
    if 'Mill' == cart.creator_type && fabric_variant.mill_id != cart.creator_id
      errors.add(:fabric_variant, :cart_mill_mismatch)
    end
  end

  def denormalize_attrs
    self.mill = fabric_variant.mill
    self.fabrium_id = fabric_variant.fabrium_id
  end

  def perform_state_update

  end
end
