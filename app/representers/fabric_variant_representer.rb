module FabricVariantRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :fabrium_id
  property :fabric_id
  property :item_number
  property :fabric_item_number
  property :color
  property :in_stock
  property :position

  nested :image do
    property :crop_width, as: :width
    property :crop_height, as: :height

    # property :image_path, as: :full
    property :thumb_path, as: :thumb
  end

  link(:self) { fabric_url(self.fabric) if self.fabric }
  link(:edit) { edit_fabric_url(self.fabric) if self.fabric }
end
