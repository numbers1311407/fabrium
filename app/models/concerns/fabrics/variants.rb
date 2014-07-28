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
      attributes.each do |key, attrs|
        if attrs['id'] && !fabric_variants.detect {|v| v.id == attrs['id'] }
          if fv = FabricVariant.find_by(id: attrs['id'])
            self.fabric_variants << fv
          end
        end
      end

      assign_nested_attributes_for_collection_association(:fabric_variants, attributes)
    end
  end
end
