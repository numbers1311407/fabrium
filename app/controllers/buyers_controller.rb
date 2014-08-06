class BuyersController < ResourceController
  before_filter :build_user, only: :new

  permit_params [
    :first_name,
    :last_name,
    :company,
    :position,
    :phone,
    :shipping_address_1,
    :shipping_address_2,
    :city,
    :postal_code,
    :country,
    :subregion,
    user_attributes: [
      :id,
      :email,
      :password,
      :password_confirmation,
      :wants_email
    ]
  ]

  protected

  def build_user
    object = build_resource
    object.build_user
  end
end
