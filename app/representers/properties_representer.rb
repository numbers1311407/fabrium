require 'representable/json/collection'

module PropertiesRepresenter
  include Representable::JSON::Collection
  items extend: PropertyRepresenter
end
