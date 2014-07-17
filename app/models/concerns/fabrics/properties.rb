module Fabrics::Properties
  extend ActiveSupport::Concern

  included do
    has_many :property_assignments, dependent: :delete_all, autosave: true, inverse_of: :fabric
    define_property_assignment_associations
  end

  module ClassMethods
    # NOTE Not sure if the individual associations will be necessary.
    #      It might be better if these were association extensions.
    def define_property_assignment_associations
      Property.kinds.each do |key, enum|
        assoc = Property::KindAssociationMap[key.to_sym]
        next unless assoc

        key = key.pluralize if :has_many == assoc

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          #{assoc} :#{key},
            -> { includes(:property).where(properties: {kind: #{enum}}) },
            class_name: 'PropertyAssignment'

          accepts_nested_attributes_for :#{key}, allow_destroy: true, reject_if: :property_assignments_filter
        RUBY

      end
    end

    def has_properties(properties)
      joins(:property_assignments).where(property_assignments: { property: properties })
    end
    alias :has_property :has_properties
  end

  def property_assignments_filter(attributes)
    prop_id = attributes["property_id"]
    ass_id = attributes["id"]

    retv = prop_id.blank? || 
      # don't add assignments for keywords that don't exist
      !Property.exists?(prop_id) || 
      # don't add duplicate assignments
      (foo = ass_id && PropertyAssignment.where(property_id: prop_id, fabric_id: id).where.not(id: ass_id).exists?)

    retv
  end
end
