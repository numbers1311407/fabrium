class MillsController < ResourceController
  self.default_sort = {name: 'name', dir: 'asc'}

  before_filter :build_nested_associations, only: :edit

  permit_params Mill::PERMISSABLE_PARAMS

  custom_actions resource: [:toggle_active]
  authority_actions toggle_active: :activate

  has_scope :name do |controller, scope, value|
    scope.attr_like(:name, value)
  end

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


  def toggle_active
    object = resource
    object.active = !object.active
    object.save
  end

  protected

  helper_method :scope_options

  def scope_options
    %w(active inactive)
  end

  def build_nested_associations
  end
end
