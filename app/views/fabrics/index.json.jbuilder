json.array!(collection) do |record|
  json.extract! record, :id
  json.url resource_url(record, format: :json)
end
