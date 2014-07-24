class FabricVariant < ActiveRecord::Base
  include Authority::Abilities
  include Concerns::FabricVariants::Color
  include Concerns::FabricVariants::Image

  before_save :assign_fabrium_id

  belongs_to :fabric

  class << self
    protected

    def joins_properties
      joins(fabric: {property_assignments: :property})
    end

    def joins_properties_scope(scope_name)
      joins_properties.merge(Property.send(scope_name))
    end

    def has_property(scope_name, id)
      joins_properties_scope(scope_name).where(properties: {id: id})
    end
  end

  scope :has_fiber, ->(id) { has_property(:fibers, id) }
  scope :has_category, ->(id) { has_property(:categories, id) }
  scope :has_dye_method, ->(id) { has_property(:dye_methods, id) }
  scope :has_keyword, ->(id) { has_property(:keywords, id) }
  scope :orphans, -> { where(fabric_id: nil) }

  protected

  def assign_fabrium_id
    if fabric.present?
      if fabrium_id.blank? || fabrium_id == 'pending'
        # add 1 first, as the index defaults to 0
        i = fabric.variant_index + 1
        fabric.update_attribute(:variant_index, i)
        self.fabrium_id = "#{fabric.id}-#{i}"
      end
    elsif fabrium_id.blank?
      self.fabrium_id = 'pending'
    end
  end

  def assign_fabrium_id_after_save?
    fabric.present? && (fabrium_id.blank? || fabrium_id == 'pending')
  end

end
