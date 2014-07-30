class Fabric < ActiveRecord::Base
  include Authority::Abilities

  include Fabrics::Prices
  include Fabrics::Category
  include Fabrics::DyeMethod
  include Fabrics::Tags
  include Fabrics::Materials
  include Fabrics::Variants
  include Fabrics::Category
  include Fabrics::Weight
  include Fabrics::Mill

  # the Fabric's "Fabrium ID" is just the actual ID, but this has the same
  # scope as fabric variant for consistency
  scope :fabrium_id, ->(val) { where(id: val) }
  scope :item_number, ->(val) { where(item_number: val) }
  scope :bulk_lead_time, ->(val) { where(arel_table[:bulk_lead_time].lteq(val)) }
  scope :bulk_minimum_quality, ->(val) { where(arel_table[:bulk_minimum_quality].lteq(val)) }
  scope :sample_lead_time, ->(val) { where(arel_table[:sample_lead_time].lteq(val)) }
  scope :sample_minimum_quality, ->(val) { where(arel_table[:sample_minimum_quality].lteq(val)) }
  scope :country, ->(val) { where(country: val) }

  validates :width, numericality: { greater_than: 0 }
end
