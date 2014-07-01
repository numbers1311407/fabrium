json.pages collection.total_pages
json.perPage collection.limit_value
json.currentPage collection.current_page
json.totalItems collection.total_count
json.items collection do |object|
  json.extract! object, :id, :color
  json.url resource_url(object, format: :json)
end
