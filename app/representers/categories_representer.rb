require 'representable/json/collection'

module CategoriesRepresenter
  include Representable::JSON::Collection
  items extend: CategoryRepresenter
end
