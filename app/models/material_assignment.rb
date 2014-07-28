class MaterialAssignment < ActiveRecord::Base
  belongs_to :material, inverse_of: :material_assignments
  belongs_to :fabric
  delegate :name, to: :material, allow_nil: true
end
