require 'representable/json/collection'

module DyeMethodsRepresenter
  include Representable::JSON::Collection
  items extend: DyeMethodRepresenter
end
