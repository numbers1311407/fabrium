class FabricVariant < ActiveRecord::Base

  paginates_per 24

  include Authority::Abilities
  include FabricVariants::Color
  include FabricVariants::Image
  include FabricVariants::FabriumId

  belongs_to :fabric

  scope :orphans, ->(bool=true) { 
    bool ? where(fabric_id: nil) : where.not(fabric_id: nil)
  }

  # The first variant of a fabric.  This is the default scope for
  # the main search function unless color is a factor, in which case
  # all variants for a fabric that match the color are shown
  scope :primary, -> { orphans(false).where(position: 0) }

  #
  # Merged scopes
  #
  scope :weight, ->(*args) { joins(:fabric).merge(Fabric.weight(*args)) }
  scope :category, ->(value) { joins(:fabric).merge(Fabric.category(value)) }
  scope :material, ->(value) { joins(:fabric).merge(Fabric.material(value)) }
  scope :dye_method, ->(value) { joins(:fabric).merge(Fabric.dye_method(value)) }

  #
  # Variants delegate most of their attributes to their parent fabric.
  #
  # TODO would it be more resilient to do some kind of `method_missing`
  # solution here, since almost all attributes are delegated?
  #
  delegate(
    :tags, 
    :mill, 
    :dye_method, 
    :category, 
    :item_number, 
    :price_eu, 
    :price_us,
    :width,
    :gsm,
    :glm,
    :osy,
    :country,
    :sample_minimum_quality,
    :bulk_minimum_quality,
    :sample_lead_time,
    :bulk_lead_time,
    :variant_index,
    :tags,
    to: :fabric, allow_nil: true
  )

  scope :tags, ->(value) { 
    joins(:fabric).merge(Fabric.tags(value)).group(arel_table[:id]) 
  }
end
