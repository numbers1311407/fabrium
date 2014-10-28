module FabricRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :item_number
  property :tags
  property :width

  collection :materials do
    property :name, as: :fiber
    property :value, as: :percentage
  end

  property :dye_method do
    property :id
    property :name
  end

  property :category do
    property :id
    property :name 
  end

  property :mill do
    property :id
    property :name
  end

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

  property :country, prepare: ->(o, opts) { 
    return {} if o.blank?;

    option = CountrySelectInput::OPTIONS.detect {|opt| opt[1] == o }

    { code: o, name: option[0] }
  }

  nested :minimum_quality do
    property :sample_minimum_quality, as: :sample
    property :bulk_minimum_quality, as: :bulk
  end

  nested :lead_time do
    property :sample_lead_time, as: :sample
    property :bulk_lead_time, as: :bulk
  end

  collection :fabric_variants, as: :variants do
    property :id
    property :fabrium_id
    property :item_number
    property :color
    property :in_stock
    property :position
    property :mill_active

    nested :image do
      property :crop_width, as: :width
      property :crop_height, as: :height

      property :thumb_tiny_path, as: :tiny
      property :crop_path, as: :full
      property :thumb_path, as: :thumb
    end
  end

  link(:self) { fabric_url(self) }
  link(:edit) { edit_fabric_url(self) }
end
