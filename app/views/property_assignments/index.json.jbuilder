json.array!(@property_assignments) do |property_assignment|
  json.extract! property_assignment, :id
  json.url property_assignment_url(property_assignment, format: :json)
end
