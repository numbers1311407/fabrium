class MaterialsController < ResourceController
  include NameSearchable
  self.default_sort = {name: 'name', dir: 'asc'}
  self.layout_name = 'list_items_control'
  permit_params :name
end
