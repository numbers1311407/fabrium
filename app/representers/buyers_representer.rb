require 'representable/json/collection'

module BuyersRepresenter
  include Representable::JSON::Collection
  items extend: BuyerRepresenter
end
