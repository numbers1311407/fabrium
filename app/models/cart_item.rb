class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :fabric_variant
  belongs_to :mill
end
