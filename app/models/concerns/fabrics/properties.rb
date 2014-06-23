module Fabrics::Properties
  extend ActiveSupport::Concern

  included do
    has_many :property_assignments
    define_property_assignment_associations
  end

  module ClassMethods
    # NOTE Not sure if the individual associations will be necessary.
    #      It might be better if these were association extensions.
    def define_property_assignment_associations
      Property.kinds.each do |key, enum|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          has_many :#{key}_assignments,
            -> { joins(:property).where(properties: {kind: #{enum}}) },
            class_name: 'PropertyAssignment'
        RUBY
      end
    end

    def has_properties(properties)
      joins(:property_assignments).where(property_assignments: { property: properties })
    end
    alias :has_property :has_properties
  end
end
