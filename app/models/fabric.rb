class Fabric < ActiveRecord::Base
  include Authority::Abilities

  include Fabrics::Prices
  include Fabrics::Properties
  include Fabrics::Weight

  validates :width, numericality: { greater_than: 0 }

  belongs_to :mill
  has_many :fabric_variants, 
    -> { order(:fabrium_id) },
    dependent: :destroy
  accepts_nested_attributes_for :fabric_variants, allow_destroy: true


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
