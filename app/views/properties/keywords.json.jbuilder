json.pages collection.total_pages
json.perPage collection.limit_value
json.currentPage collection.current_page
json.totalItems collection.total_count
json.items collection do |record|
  json.extract! record, :id, :name
end
