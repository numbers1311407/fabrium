require 'representable/json/collection'

module FavoritesRepresenter
  include Representable::JSON::Collection
  items extend: FavoriteRepresenter
end
