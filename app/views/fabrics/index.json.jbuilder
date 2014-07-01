json.array!(@fabrics) do |fabric|
  json.extract! fabric, :id
  json.url fabric_url(fabric, format: :json)
end
