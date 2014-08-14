class RegistrationsController < Devise::RegistrationsController
  before_filter :handle_meta_param, only: [:new]
  before_action :configure_permitted_parameters

  after_filter :attach_public_cart, on: :create

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

    # NOTE this works in the implementation because meta_type is always
    # set in the params, either via the `meta` param or submitted with
    # the form.  This way the user knows how to build the meta.
    object.build_meta unless object.meta.present?

    # if registering a new mill user, then this user is that mill's
    # creator
    if object.is_mill?
      object.meta.creator = object
    end

    self.resource = object
  end

  def handle_meta_param
    if !params[:meta] || !%w(mill buyer).member?(params[:meta])
      render_404
      return false
    end
  end

  def permitted_meta_attributes 
    # TODO separate these, the trick is determining the meta type.  Not
    # too much of a trick probably, but more than I care to do right now.
    [ Buyer::PERMISSABLE_PARAMS, Mill::PERMISSABLE_PARAMS ].flatten.uniq
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

  def attach_public_cart
    if resource.persisted? && resource.is_buyer? && cart_id = session[:public_cart_id]
      Cart.claim_cart(cart_id, resource.meta)
    end
  end

end
