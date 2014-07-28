module FabricVariants
  module FabriumId
    extend ActiveSupport::Concern

    included do
      before_save :assign_fabrium_id
    end

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
  end
end
