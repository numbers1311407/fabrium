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

crumb :fabric do
  text = "Fabrics ##{resource.id}"

  if !resource.updatable_by?(current_user)
    link text, resource
  else
    parent :resource, name: text
  end
end

crumb :edit_profile do
  link "Edit Your Profile"
end

crumb :blocklist do
  link "Edit Your Approved Domains"
end
