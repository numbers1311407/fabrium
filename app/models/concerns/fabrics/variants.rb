module Fabrics
  module Variants
    extend ActiveSupport::Concern

    included do
      has_many :fabric_variants, 
        -> { order(:position) },
        dependent: :destroy

      accepts_nested_attributes_for :fabric_variants, allow_destroy: true
    end

    def fabric_variants_attributes=(attributes)
      # This bit is necessary to allow the *assigning* of fabric_variants by ID.
      # Normally `accepts_nested_attributes_for` only uses ID for update, and
      # assiging say `fabric_variants_ids = [{id: 1}]` on a new record (with
      # no previous variants) will throw an exception.
      #
      # This is no doubt by design as it makes sense in the typical situation
      # where the nested records are managed completely in the parent form, but
      # fabric variants are actually created in a popup form and assigned to the
      # fabric afterward (essentially to allow for the pre-upload of images before
      # the record is persisted)
      #
      # Here the fabric variant is associated *before* the default implementation is
      # called which would update all the already associated variants.  In this way
      # a variant is associated if necessary, *then* the variants are all updated
      # per the passed params
      #
      attributes.each do |key, attrs|
        id = attrs['id'].to_i
        if !id.zero? && !fabric_variant_ids.member?(id)
          if fv = FabricVariant.find_by(id: id)
            self.fabric_variants << fv
          end
        end
      end

      # calls the dynamic "super"
      assign_nested_attributes_for_collection_association(:fabric_variants, attributes)
    end
  end
end
