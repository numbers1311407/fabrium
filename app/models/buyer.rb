class Buyer < ActiveRecord::Base
  has_one :user

  has_many :buyer_mills
  has_many :preferred_buyer_mills, -> { preferred }, class_name: 'BuyerMill'
  has_many :blocked_buyer_mills, -> { blocked }, class_name: 'BuyerMill'

  has_many :preferred_mills, through: :preferred_buyer_mills, source: :mill, class_name: 'Mill'
  has_many :blocked_mills, through: :blocked_buyer_mills, source: :mill, class_name: 'Mill'
end
