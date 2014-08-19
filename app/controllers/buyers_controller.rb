class BuyersController < ResourceController
  permit_params Buyer::PERMISSABLE_PARAMS + [
    user_attributes: [
      :id,
      :email,
      :password,
      :password_confirmation,
      :wants_email
    ]
  ]

  has_scope :scope do |controller, scope, value|
    case value
    when 'pending' then scope = scope.pending
    end

    scope
  end

  has_scope :name do |controller, scope, value|
    scope.attrs_like([:first_name, :last_name], value)
  end

  has_scope :first_name do |controller, scope, value|
    scope.attr_like(:first_name, value, pattern: "%%%s%")
  end

  has_scope :last_name do |controller, scope, value|
    scope.attr_like(:last_name, value, pattern: "%%%s%")
  end

  has_scope :company do |controller, scope, value|
    scope.attr_like(:company, value, pattern: "%%%s%")
  end

  has_scope :email do |controller, scope, value|
    scope.joins(:user).merge User.attr_like(:email, value, pattern: "%%%s%")
  end

  add_collection_filter_scope :collection_filter_includes

  protected

  def scope_options
    scopes = %w(pending)
  end
  helper_method :scope_options

  def collection_filter_includes(object)
    object.includes(:user)
  end

  def after_commit_redirect_path
    if current_user.is_admin?
      collection_path
    else
      edit_resource_path
    end
  end
end
