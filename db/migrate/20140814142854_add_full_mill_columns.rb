class AddFullMillColumns < ActiveRecord::Migration
  def change
    # Profile
    add_column :mills, :shipping_address_1, :string
    add_column :mills, :shipping_address_2, :string
    add_column :mills, :city, :string
    add_column :mills, :subregion, :string
    add_column :mills, :country, :string
    add_column :mills, :phone, :string
    add_column :mills, :postal_code, :string
    add_column :mills, :product_type, :string
    add_column :mills, :monthly_total_capacity, :string
    add_column :mills, :year_established, :string
    add_column :mills, :number_of_employees, :string
    add_column :mills, :major_markets, :string
    add_column :mills, :major_customers, :string

    # Production
    add_column :mills, :sample_minimum_quality, :integer, default: 0
    add_column :mills, :bulk_minimum_quality, :integer, default: 0
    add_column :mills, :sample_lead_time, :integer, default: 0
    add_column :mills, :bulk_lead_time, :integer, default: 0

    # Collection
    add_column :mills, :seasonal, :boolean, default: false
    add_column :mills, :seasonal_count, :integer, default: 0
    add_column :mills, :designs_per_season, :integer, default: 0
    add_column :mills, :designs_in_archive, :integer, default: 0

    # Operations
    add_column :mills, :spinning_monthly_capacity, :integer, default: 0
    add_column :mills, :weaving_knitting_monthly_capacity, :integer, default: 0
    add_column :mills, :dying_monthly_capacity, :integer, default: 0
    add_column :mills, :finishing_monthly_capacity, :integer, default: 0
    add_column :mills, :printing_monthly_capacity, :integer, default: 0
    add_column :mills, :printing_methods, :integer, default: 0
    add_column :mills, :printing_max_colors, :integer, default: 0

    # Color and testing
    add_column :mills, :automatic_lab_dipping, :boolean, default: false
    add_column :mills, :spectrophotometer, :boolean, default: false
    add_column :mills, :light_box, :boolean, default: false
    add_column :mills, :internal_lab, :boolean, default: false
    add_column :mills, :light_sources, :boolean, default: false
    add_column :mills, :testing_capabilities, :string

    # Quality Control
    add_column :mills, :inspection_stages, :string
    add_column :mills, :inspection_system, :string

    # Fabric Exhibitions
    add_column :mills, :years_attending_premiere_vision, :integer, defalt: 0
    add_column :mills, :years_attending_texworld, :integer, defalt: 0
  end
end
