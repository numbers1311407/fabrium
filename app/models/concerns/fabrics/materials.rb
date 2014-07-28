module Fabrics
  module Materials
    extend ActiveSupport::Concern

    included do
      has_many :materials, 
        -> { includes(:material) },
        class_name: 'MaterialAssignment'

      accepts_nested_attributes_for :materials, 
        allow_destroy: true,
        reject_if: :material_filter

      scope :material, ->(id) { 
        table = Material.arel_table
        joins(:materials).where(material_assignments: {material_id: id})
      }
    end

    protected

    # TODO This is legacy from when properties were kept in one table.  How
    # much of it is necessary? Any?
    def material_filter(attributes)
      material_id = attributes["material_id"]
      ass_id = attributes["id"]

      retv = material_id.blank? || 
        !Material.exists?(material_id) || 
        # don't add duplicate assignments
        (foo = ass_id && MaterialAssignment.where(material_id: material_id, fabric_id: id).where.not(id: ass_id).exists?)

      retv
    end
  end
end
