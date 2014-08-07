class Mill < ActiveRecord::Base
  include Authority::Abilities

  include Mills::FilteredDomains

  # the user who made the cart (along with registration)
  belongs_to :creator, class_name: 'User'

  # the users who have this cart as meta (should include the creator)
  has_many :users, as: :meta, dependent: :destroy

  # fabrics the mill creates
  has_many :fabrics

  # carts for a mill include carts which they've created for buyers, 
  # and "subcarts" which are copies of buyer created carts that are
  # split up by cart_items, allowing mills to manage carts when the
  # order went to multiple mills
  has_many :carts

  # cart_items are a denormalized association
  has_many :cart_items


  validates :name, presence: true, uniqueness: true


  scope :active, ->(v=true) { where(active: v) }


  def pending_carts
    carts.created_by_mill(self).state(:mill_build)
  end
end
