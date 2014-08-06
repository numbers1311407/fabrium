class Favorite < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :user
  belongs_to :fabric

  validates_presence_of :fabric
  validates_presence_of :user

  scope :for_user, ->(user) { where(user: user) }
  scope :for_fabric, ->(variant) { where(fabric: variant) } 
end
