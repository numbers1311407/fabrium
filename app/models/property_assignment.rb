class PropertyAssignment < ActiveRecord::Base
  belongs_to :property, inverse_of: :property_assignments
  belongs_to :fabric

  delegate :name, to: :property, allow_nil: true
end
