require 'representable/json/collection'

module MillsRepresenter
  include Representable::JSON::Collection
  items extend: MillRepresenter
end
