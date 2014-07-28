require 'representable/json/collection'

module MaterialsRepresenter
  include Representable::JSON::Collection
  items extend: MaterialRepresenter
end
