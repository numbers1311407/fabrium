class Favorite < ActiveRecord::Base
  include Authority::Abilities

  after_create :increment_user_favorite_count
  after_destroy :decrement_user_favorite_count

  belongs_to :user
  belongs_to :fabric

  validates_presence_of :fabric
  validates_presence_of :user

  scope :for_user, ->(user) { where(user: user) }
  scope :for_fabric, ->(variant) { where(fabric: variant) } 

  protected

  def increment_user_favorite_count
    self.user.try(:increment!, :favorites_count)
  end

  def decrement_user_favorite_count
    self.user.try(:decrement!, :favorites_count)
  end
end
