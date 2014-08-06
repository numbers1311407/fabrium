class Buyer < ActiveRecord::Base
  include Authority::Abilities

  has_one :user, as: :meta, dependent: :destroy

  has_many :buyer_mills
  has_many :preferred_buyer_mills, -> { preferred }, class_name: 'BuyerMill'
  has_many :blocked_buyer_mills, -> { blocked }, class_name: 'BuyerMill'

  has_many :preferred_mills, through: :preferred_buyer_mills, source: :mill, class_name: 'Mill'
  has_many :blocked_mills, through: :blocked_buyer_mills, source: :mill, class_name: 'Mill'

  has_many :carts, -> { exclude_subcarts }

  def pending_carts
    carts.created_by_buyer(self).state(:buyer_build)
  end
end
