class Mill < ActiveRecord::Base
  include Authority::Abilities

  PERMISSABLE_PARAMS = [
    :active,
    :automatic_lab_dipping, 
    :bulk_lead_time, 
    :bulk_minimum_quality, 
    :city, 
    :country, 
    :creator_id,
    :designs_in_archive, 
    :designs_per_season, 
    :domain_filter, 
    :domain_names,
    :dying_monthly_capacity, 
    :finishing_monthly_capacity, 
    :inspection_stages, 
    :inspection_system, 
    :internal_lab, 
    :light_box, 
    :light_sources, 
    :major_customers, 
    :major_markets, 
    :name,
    :number_of_employees, 
    :postal_code, 
    :printing_max_colors, 
    :printing_methods, 
    :printing_monthly_capacity, 
    :product_type, 
    :sample_lead_time, 
    :sample_minimum_quality, 
    :seasonal, 
    :seasonal_count, 
    :shipping_address_1, 
    :shipping_address_2, 
    :spectrophotometer, 
    :spinning_monthly_capacity,
    :subregion, 
    :testing_capabilities, 
    :weaving_knitting_monthly_capacity, 
    :year_established, 
    :years_attending_premiere_vision, 
    :years_attending_texworld,
    references_attributes: [
      :id,
      :name,
      :email,
      :phone,
      :company,
      :_destroy
    ],
    contacts_attributes: [
      :id,
      :kind,
      :email,
      :name,
      :phone,
      :_destroy
    ],
    agents_attributes: [
      :id,
      :contact,
      :email,
      :phone,
      :country,
      :_destroy
    ]
  ]

  include Mills::FilteredDomains

  # the user who made the cart (along with registration)
  belongs_to :creator, class_name: 'User'

  # the users who have this cart as meta (should include the creator)
  has_many :users, as: :meta, dependent: :destroy

  # fabrics the mill creates
  has_many :fabrics
  # fabric variants of those fabrics 
  # (denormalized, belongs to both fabric and that fabric's mill)
  has_many :fabric_variants

  # carts for a mill include carts which they've created for buyers, 
  # and "subcarts" which are copies of buyer created carts that are
  # split up by cart_items, allowing mills to manage carts when the
  # order went to multiple mills
  has_many :carts

  # cart_items are a denormalized association
  has_many :cart_items

  has_many :contacts, class_name: 'MillContact'
  has_many :agents, class_name: 'MillAgent'
  has_many :references, class_name: 'MillReference'

  accepts_nested_attributes_for :contacts, allow_destroy: true
  accepts_nested_attributes_for :agents, allow_destroy: true
  accepts_nested_attributes_for :references, allow_destroy: true

  scope :active, ->(v=true) { where(active: v) }

  #
  # Validations
  #
  validates :name, presence: true, uniqueness: true
  validates :shipping_address_1, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
  validates :subregion, presence: true
  validates :product_type, presence: true
  validates :year_established, presence: true
  validates :number_of_employees, presence: true
  validates :major_markets, presence: true
  validates :sample_lead_time, presence: true
  validates :bulk_lead_time, presence: true
  validates :sample_minimum_quality, presence: true
  validates :bulk_minimum_quality, presence: true
  validates :seasonal, inclusion: {in: [true, false]}
  validates :designs_per_season, presence: true
  validates :designs_in_archive, presence: true
  validates :spinning_monthly_capacity, presence: true
  validates :weaving_knitting_monthly_capacity, presence: true
  validates :dying_monthly_capacity, presence: true
  validates :finishing_monthly_capacity, presence: true
  validates :printing_monthly_capacity, presence: true
  validates :printing_methods, presence: true
  validates :printing_max_colors, presence: true
  validates :automatic_lab_dipping, inclusion: {in: [true, false]}
  validates :spectrophotometer, inclusion: {in: [true, false]}
  validates :light_box, inclusion: {in: [true, false]}
  validates :internal_lab, inclusion: {in: [true, false]}
  validates :light_sources, presence: true
  validates :inspection_stages, presence: true
  validates :inspection_system, presence: true
  validates :years_attending_premiere_vision, presence: true
  validates :years_attending_texworld, presence: true

  def pending_carts
    carts.created_by_mill(self).state(:mill_build)
  end
end
