module MillRepresenter
  include Roar::Representer::JSON

  property :id  
  property :name  

  property :shipping_address_1
  property :shipping_address_2
  property :city
  property :subregion
  property :country
  property :phone
  property :postal_code
  property :product_type
  property :year_established
  property :number_of_employees
  property :major_markets
  property :major_customers
  property :seasonal
  property :seasonal_count
  property :designs_per_season
  property :designs_in_archive

  property :sample_lead_time
  property :bulk_lead_time

  property :sample_minimum_quality
  property :bulk_minimum_quality

  property :monthly_total_capacity
  property :spinning_monthly_capacity
  property :weaving_knitting_monthly_capacity
  property :dying_monthly_capacity
  property :finishing_monthly_capacity
  property :printing_monthly_capacity

  property :printing_methods
  property :printing_max_colors
  property :automatic_lab_dipping
  property :spectrophotometer
  property :light_box
  property :internal_lab
  property :light_sources
  property :testing_capabilities
  property :inspection_stages
  property :inspection_system
  property :years_attending_premiere_vision
  property :years_attending_texworld

  # collection :references do
  #   property :name
  #   property :email
  #   property :phone
  #   property :company
  # end

  collection :contacts do
    property :name
    property :email
    property :phone
    property :kind, as: :job_title
  end

  collection :agents do
    property :contact, as: :name
    property :email
    property :phone
    property :country
  end
end
