class FabricVariant < ActiveRecord::Base
  include Authority::Abilities
  include Concerns::FabricVariants::Color
  include Concerns::FabricVariants::Image

  before_save :assign_fabrium_id

  belongs_to :fabric

  class << self
    protected

    # def joins_properties
    #   joins(fabric: :properties)
    # end

    # def joins_properties_scope(scope_name)
    #   joins_properties.merge(Property.send(scope_name))
    # end

    # def has_property(scope_name, id)
    #   joins_properties_scope(scope_name).where(properties: {id: id})
    # end

    def has_property(scope_name, id)
      p = Property.arel_table
      kind = Property.kinds[scope_name.to_sym]
      conditions = [ p[:kind].eq(kind), p[:id].eq(id) ].inject(:and)

      joins(fabric: :properties).where(conditions)
    end
    
  end

  # scope :has_fiber, ->(id) { has_property(:fibers, id) }
  # scope :has_category, ->(id) { has_property(:categories, id) }
  # scope :has_dye_method, ->(id) { has_property(:dye_methods, id) }
  # scope :has_keyword, ->(id) { has_property(:keywords, id) }

  scope :orphans, -> { where(fabric_id: nil) }

  scope :weight, ->(v, units=nil) { 
    conditions = {fabrics: {}}
    conditions[:fabrics][Fabric.parse_units(units)] = v
    joins(:fabric).where(conditions)
  }

  scope :keywords, ->(list) { 
    list = list.split(",") if list.is_a?(String)

    # Very hacky feeling keyword search:
    #
    # Join on properties where property type is keyword and property
    # name is IN the list of keywords passed, which will return duplicates
    # if an item is tagged with more than one keyword in the list.
    # Group the results based in ID, and specify HAVING COUNT of at
    # least the list size.  This should mean that records that do not
    # match ALL of the tags are dropped from the results.
    #
    table = Property.arel_table
    kind = Property.kinds[:keyword]
    conditions = [ table[:kind].eq(kind), table[:name].in(list) ].inject(:and)

    group(arel_table[:id]).
      joins(fabric: :properties).
      where(conditions).
      having("COUNT(*) >= ?", list.length)
  }

  scope :category, ->(value) { has_property(:category, value) }
  scope :fiber, ->(value) { has_property(:fiber, value) }
  scope :dye_method, ->(value) { has_property(:dye_method, value) }

  scope :properties, ->(hash) {
    table = Property.arel_table
    conditions = []
    keyword_list = nil

    hash.each do |key, value|
      condition = []

      if 'keywords' == key 
        value = value.split(",") if value.is_a?(String)
        keyword_list = value
        kind = Property.kinds[:keyword]
        condition = [ table[:kind].eq(kind), table[:name].in(value) ]
      else
        kind = Property.kinds[key.to_sym]
        condition = [ table[:kind].eq(kind), table[:id].eq(value) ]
      end

      conditions << condition.inject(:and)
    end

    conditions = conditions.inject(:or)

    scoped = joins(fabric: :properties).where(conditions)

    if keyword_list
      scoped = scoped.group(arel_table[:id]).having("COUNT(*) >= ?", keyword_list.length)
    end

    scoped
  }

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
