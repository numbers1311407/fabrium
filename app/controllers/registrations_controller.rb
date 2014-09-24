class RegistrationsController < Devise::RegistrationsController
  before_filter :handle_meta_param, only: [:new]
  before_action :configure_permitted_parameters, only: [:update, :create]

  include Roar::Rails::ControllerAdditions
  represents :json, User

  # Mills can send "public" carts to (buyer) users who have not yet signed 
  # up, # whereupon eventually signing up, the public cart should be assigned
  # to the new buyer and no longer publicly accessible.
  #
  # The current implementation of this feature works by assigning the ID of
  # the public cart to the session when it is viewed.  When a new user is 
  # created, we look for a public cart ID in the session and "claim" that cart
  # if that cart is still in an unclaimed state.  This is far from a secure
  # transaction, but then again there are no real negative ramifications of
  # missing a claimed cart.  Worst case scenario: the cart ends up assigned to
  # the wrong buyer, or no buyer, and the new user asks the mill to make them
  # another.  If this flow is not adequate we can come up with something else.
  # 
  after_filter :attach_public_cart, on: :create

  # Send users to sign up on inactive sign out (not home page)
  # (this only applies of course if user is Timeoutable)
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  # Refresh the profile page after update
  def after_update_path_for(resource)
    edit_user_registration_path
  end

  # The new action expects a `meta` param designating which type of
  # user we are building.  As defined by the routes, this param should
  # always exist (and 404 given an in appropriate meta type)
  def new
    build_resource({meta_type: params[:meta].classify})
    respond_with self.resource
  end

  # /profile.json
  #
  # For use in the client JS.  This should only be a json request
  #
  def profile
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    respond_with self.resource
  end

  protected

  def build_resource(hash=nil)
    object = resource_class.new_with_session(hash || {}, session)

    # If there's a public cart in the session, we're going to assume this
    # buyer received a cart from a mill and has visited the public cart
    # page.  It is not currently required that the resulting user has
    # the same email as that sent by the mill, only that they've visited
    # the cart in the current session.
    #
    # The point of this is both to track users created as a result of
    # mill "invites", and to prevent the need for user confirmation, as
    # all invited users skip both the confirm & pending steps.  This means
    # that users resulting from mill sent cart "invites" should be able
    # to proceed directly to editing their cart, whether or not their
    # email domain is pre-approved.
    #
    # Note if for whatever reason the mill specified by the session id
    # cannot be found, user creation will not be prevented, but the user
    # will require confirmation.
    #
    if session[:public_cart_mill]
      object.invited_by = Mill.find_by(id: session[:public_cart_mill])
    end

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
    case params[resource_name] && params[resource_name]["meta_type"]
    when 'Buyer' then Buyer::PERMISSABLE_PARAMS
    when 'Mill' then Mill::PERMISSABLE_PARAMS
    else []
    end
  end

  def configure_permitted_parameters
    user_attributes = [
      :email, 
      :password, 
      :password_confirmation, 
      :current_password,
      :wants_email, 
      :meta_type
    ]

    permits = [user_attributes]

    if 'create' == params[:action]
      permits << {meta_attributes: permitted_meta_attributes}
      devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(permits) }
    else
      devise_parameter_sanitizer.for(:account_update) {|u| u.permit(permits) }
    end
  end

  # 
  def attach_public_cart
    if resource.persisted? && resource.is_buyer? && cart_id = session[:public_cart_id]
      Cart.claim_cart(cart_id, resource.meta)
    end
  end

end
