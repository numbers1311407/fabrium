class RegistrationsController < Devise::RegistrationsController
  before_filter :handle_meta_param, only: [:new]
  before_action :configure_permitted_parameters

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def new
    build_resource({meta_type: params[:meta].classify})
    respond_with self.resource
  end

  protected

  def build_resource(hash=nil)
    object = resource_class.new_with_session(hash || {}, session)
    object.build_meta unless object.meta.present?
    self.resource = object
  end

  def handle_meta_param
    if !params[:meta] || !%w(mill buyer).member?(params[:meta])
      render_404
      return false
    end
  end

  def permitted_meta_attributes 
    attributes = {
      buyer: [
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
        :subregion
      ],

      mill: [
        :name
      ]
    }

    # TODO separate these, the trick is determining the meta type.  Not
    # too much of a trick probably, but more than I care to do right now.
    attributes[:buyer].concat attributes[:mill]
  end

  def configure_permitted_parameters
    user_attributes = [
      :email, 
      :password, 
      :password_confirmation, 
      :wants_email, 
      :meta_type
    ]

    devise_parameter_sanitizer.for(:sign_up) do |u| 
      permits = [{meta_attributes: permitted_meta_attributes}]
      permits.concat(user_attributes)

      u.permit(permits)
    end
  end

end
