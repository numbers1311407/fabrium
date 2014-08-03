class Buyer < ActiveRecord::Base
  has_one :user, as: :meta, dependent: :destroy

  has_many :buyer_mills
  has_many :preferred_buyer_mills, -> { preferred }, class_name: 'BuyerMill'
  has_many :blocked_buyer_mills, -> { blocked }, class_name: 'BuyerMill'

  has_many :preferred_mills, through: :preferred_buyer_mills, source: :mill, class_name: 'Mill'
  has_many :blocked_mills, through: :blocked_buyer_mills, source: :mill, class_name: 'Mill'

  has_many :carts
  has_many :buyer_carts, -> { buyer_created }, class_name: 'Cart'
  has_many :mill_carts, -> { mill_created }, class_name: 'Cart'

  def pending_cart
    scoped = buyer_carts.state(:buyer)
    scoped.first || scoped.create
  end
end
