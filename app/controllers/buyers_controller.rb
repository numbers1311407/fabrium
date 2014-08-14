class BuyersController < ResourceController
  # TODO there is no buyers.new, is there?  Look into this.
  # before_filter :build_user, only: :new

  permit_params Buyer::PERMISSABLE_PARAMS + [
    user_attributes: [
      :id,
      :email,
      :password,
      :password_confirmation,
      :wants_email
    ]
  ]

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

  def collection_filter_includes(object)
    object.includes(:user)
  end

  # def build_user
  #   object = build_resource
  #   object.build_user
  # end
end
