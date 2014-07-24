crumb :root do
  link "FOO", root_path
end

crumb :resources do |options|
  options ||= {}
  link st(:title, action: :index), options[:parent_path] || collection_path
end

crumb :edit_singleton_resource do
  link st(:title), edit_resource_path(resource)
end

crumb :new_resource do |options|
  link st(:title), new_resource_path
  parent :resources, options
end

crumb :edit_resource do |options|
  link st(:title), edit_resource_path(resource)
  parent :resources, options
end
