module FabricVariantRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :fabrium_id, as: :id
  property :fabric_id
  property :item_number
  property :color
  property :in_stock
  property :position

  nested :image do
    # property :image_path, as: :full
    property :thumb_path, as: :thumb
  end
end
