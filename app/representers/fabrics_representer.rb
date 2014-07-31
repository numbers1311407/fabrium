require 'representable/json/collection'

module FabricsRepresenter
  include Representable::JSON::Collection
  items extend: FabricRepresenter
end
