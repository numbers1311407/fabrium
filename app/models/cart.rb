class Cart < ActiveRecord::Base
  include Authority::Abilities

  has_many :cart_items
  accepts_nested_resources_for :cart_items

  belongs_to :mill

  belongs_to :buyer
end
