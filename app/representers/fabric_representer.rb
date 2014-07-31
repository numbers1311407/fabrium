module FabricRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :item_number
  property :tags

  property :dye_method
  property :category
  property :width

  nested :price do
    nested :us do
      property :price_us_min, as: :min
      property :price_us_max, as: :max
    end

    nested :eu do
      property :price_eu_min, as: :min
      property :price_eu_max, as: :max
    end
  end

  nested :weight do
    property :gsm
    property :glm
    property :osy
  end

  property :country

  nested :minimum_quality do
    property :sample_minimum_quality, as: :sample
    property :bulk_minimum_quality, as: :bulk
  end

  nested :lead_time do
    property :sample_lead_time, as: :sample
    property :bulk_lead_time, as: :bulk
  end

  collection :fabric_variants, extend: FabricVariantRepresenter, as: :variants

  link(:self) { fabric_url(self) }
  link(:edit) { edit_fabric_url(self) }
end
