class Buyer < ActiveRecord::Base
  include Authority::Abilities

  has_one :user, as: :meta, dependent: :destroy

  accepts_nested_attributes_for :user

  phony_normalize :phone, :default_country_code => 'US'

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :company, presence: true
  validates :position, presence: true
  validates :phone, presence: true, phony_plausible: true
  validates :shipping_address_1, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
  validates :subregion, presence: true

  has_many :buyer_mills
  has_many :preferred_buyer_mills, -> { preferred }, class_name: 'BuyerMill'
  has_many :blocked_buyer_mills, -> { blocked }, class_name: 'BuyerMill'

  has_many :preferred_mills, through: :preferred_buyer_mills, source: :mill, class_name: 'Mill'
  has_many :blocked_mills, through: :blocked_buyer_mills, source: :mill, class_name: 'Mill'

  has_many :carts, -> { exclude_subcarts }

  def name
    [first_name, last_name].compact.join(" ")
  end

  def pending_carts
    carts.created_by_buyer(self).state(:buyer_build)
  end
end
