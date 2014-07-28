require 'representable/json/collection'

module TagsRepresenter
  include Representable::JSON::Collection
  items extend: TagRepresenter
end
