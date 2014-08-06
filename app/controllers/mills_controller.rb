class MillsController < ResourceController
  self.default_sort = {name: 'name', dir: 'asc'}

  has_scope :id do |controller, scope, value|
    scope.where(id: value.split(','))
  end

  has_scope :scope do |controller, scope, value|
    case value
    when 'active'
      scope = scope.active
    when 'inactive'
      scope = scope.active(false)
    end

    scope
  end

  permit_params [
    :name,
    :domain_filter, 
    :domain_names,
    :active
  ]

  protected

  helper_method :scope_options

  def scope_options
    %w(active inactive)
  end
end
