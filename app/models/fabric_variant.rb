class FabricVariant < ActiveRecord::Base

  paginates_per 24

  include Authority::Abilities
  include FabricVariants::Color
  include FabricVariants::Image
  include FabricVariants::FabriumId

  belongs_to :fabric

  has_many :favorites
  has_many :favoriting_users, through: :favorites, source: :user

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
  scope :category, ->(val) { joins(:fabric).merge(Fabric.category(val)) }
  scope :material, ->(val) { joins(:fabric).merge(Fabric.material(val)) }
  scope :dye_method, ->(val) { joins(:fabric).merge(Fabric.dye_method(val)) }
  scope :mills, ->(val) { joins(:fabric).merge(Fabric.mills(val)) }
  scope :country, ->(val) { joins(:fabric).merge(Fabric.country(val)) }
  scope :not_mills, ->(val) { joins(:fabric).merge(Fabric.not_mills(val)) }
  scope :active_mills, ->{ joins(:fabric).merge(Fabric.active_mills) }
  scope :tags, ->(val) { joins(:fabric).merge(Fabric.tags(val)) }
  scope :bulk_lead_time, ->(val) { joins(:fabric).merge(Fabric.bulk_lead_time(val)) }
  scope :bulk_minimum_quality, ->(val) { joins(:fabric).merge(Fabric.bulk_minimum_quality(val)) }
  scope :sample_lead_time, ->(val) { joins(:fabric).merge(Fabric.bulk_lead_time(val)) }
  scope :sample_minimum_quality, ->(val) { joins(:fabric).merge(Fabric.bulk_minimum_quality(val)) }

  scope :favorites, ->(user) { joins(:favorites).merge(Favorite.for_user(user)) }
  scope :in_stock, ->(val=true) { where(in_stock: val) }

  scope :fabrium_id, ->(val) { 
    # if a plain number is passed, search by parent id, otherwise search variants
    if val.to_s =~ /^\d+$/
      joins(:fabric).merge(Fabric.fabrium_id(val))
    else
      where(fabrium_id: val)
    end
  }
  scope :item_number, ->(val) { 
    joins(:fabric).where(arel_table[:item_number].eq(val).or(Fabric.arel_table[:item_number].eq(val))) 
  }

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

end
