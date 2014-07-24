require 'representable/json/collection'

module FabricVariantsRepresenter
  include Representable::JSON::Collection
  items extend: FabricVariantRepresenter 
end
