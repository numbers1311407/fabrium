class MillsController < ResourceController
  self.default_sort = {name: 'name', dir: 'asc'}

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

  def after_commit_redirect_path
    if current_user.is_admin?
      collection_path
    else
      edit_resource_path
    end
  end

  helper_method :scope_options

  def scope_options
    %w(active inactive)
  end
end
