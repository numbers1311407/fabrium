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
  text = t(:fabric, id: resource.id, scope: :breadcrumbs)

  if !resource.updatable_by?(current_user)
    link text, resource
  else
    parent :resource, name: text
  end
end

crumb :edit_profile do
  link t(:edit_profile, scope: :breadcrumbs)
end

crumb :edit_mill do |options|
  link st(:title, options)

  if current_user.is_admin?
    parent :resources, options
  end
end

crumb :edit_buyer do |options|
  link st(:title, options)

  if current_user.is_admin?
    parent :resources, options
  end
end

crumb :blocklist do
  link t(:blocklist, scope: :breadcrumbs)
end
