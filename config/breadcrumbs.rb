crumb :root do
  link "Home", "/"
end

crumb :resources do |options|
  link st(:title, action: :index), collection_path
end


crumb :edit_singleton_resource do
  link st(:title), edit_resource_path(resource)
end

crumb :resource do |options|
  link st(:title, options)
  parent :resources, options
end

crumb :new_resource do |options|
  link st(:title, options)
  parent :resources, options
end

crumb :edit_resource do |options|
  link st(:title, options)
  parent :resources, options
end
