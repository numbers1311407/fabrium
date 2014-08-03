class MillsController < ResourceController
  self.default_sort = {name: 'name', dir: 'asc'}

  has_scope :id do |controller, scope, value|
    scope.where(id: value.split(','))
  end

  permit_params [
    :name,
    :domain_filter, 
    :domain_names
  ]
end
