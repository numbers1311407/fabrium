class FabricVariant < ActiveRecord::Base
  include Authority::Abilities

  include FabricVariants::Color

  belongs_to :fabric

  class << self
    protected

    def joins_properties
      joins(fabric: {property_assignments: :property})
    end

    def joins_properties_scope(scope_name)
      joins_properties.merge(Property.send(scope_name))
    end
  end

  scope :has_property, ->(scope_name, id) {
    joins_properties_scope(scope_name).where(properties: {id: id})
  }
  scope :has_fiber, ->(id) { has_property(:fibers, id) }
  scope :has_category, ->(id) { has_property(:categories, id) }
  scope :has_dye_method, ->(id) { has_property(:dye_methods, id) }
  scope :has_keyword, ->(id) { has_property(:keywords, id) }
end
