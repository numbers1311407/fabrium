class ApprovedDomainsController < ResourceController
  self.default_sort = {name: 'name', dir: 'asc'}

  permit_params :name, :entity

  has_scope :entity do |controller, scope, value|
    case value
    when 'mill' then scope = scope.for_mill
    when 'buyer' then scope = scope.for_buyer
    end

    scope
  end
end
