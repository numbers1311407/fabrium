class CartItem < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :cart
  belongs_to :fabric_variant
  belongs_to :mill
end
