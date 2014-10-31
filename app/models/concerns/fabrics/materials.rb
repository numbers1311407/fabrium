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

      validates_presence_of :materials
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

    module ClassMethods

      # chainable "scope" for material search by id and percentage that joins
      # the material assignments table by alias
      def has_material(id, percentage=nil)
        return none unless id.respond_to?(:to_s)
        suffix = Digest::SHA1.hexdigest(id.to_s)[0..6]
        n = "ma_#{suffix}"
        conditions = {}
        conditions["#{n}.material_id"] = id
        conditions["#{n}.value"] = percentage if percentage

        joins("INNER JOIN material_assignments #{n} ON #{n}.fabric_id = fabrics.id AND #{sanitize_sql_hash_for_conditions(conditions)}")
      end
    end
  end
end
