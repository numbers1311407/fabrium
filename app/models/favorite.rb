class Favorite < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :user
  belongs_to :fabric_variant

  validates_presence_of :fabric_variant
  validates_presence_of :user

  scope :for_user, ->(user) { where(user: user) }
  scope :for_fabric_variant, ->(variant) { where(fabric_variant: variant) } 
end
