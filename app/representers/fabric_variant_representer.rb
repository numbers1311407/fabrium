module FabricVariantRepresenter
  include Roar::Representer::JSON

  property :id  
  property :fabrium_id
  property :item_number
  property :color
  property :in_stock

  nested :image do
    property :image_path, as: :full
    property :thumb_path, as: :thumb
  end
end
