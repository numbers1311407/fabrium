class Mill < ActiveRecord::Base
  include Authority::Abilities

  scope :active, ->{ where(active: true) }

  has_many :fabrics
  has_many :cart_items
  has_many :carts
  belongs_to :user
  has_many :users
end
