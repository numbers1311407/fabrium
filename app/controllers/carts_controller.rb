class CartsController < ResourceController
  custom_actions resource: [:pending_cart]
  authority_actions pending_cart: :read

  skip_before_filter :authenticate_user!, :only => [:show]

  add_collection_filter_scope :collection_filter_mill_carts
  add_collection_filter_scope :collection_filter_buyer_carts

  permit_params [
    :buyer_email,
    :buyer_email_confirmation,
    cart_items_attributes: [
      :id, 
      :notes, 
      :sample_yardage, 
      :tracking_number, 
      :fabric_variant_id,
      :_destroy
    ]
  ]

  #
  # GET /cart
  #
  def pending_cart
    object = resource

    respond_with(object) do |wants|
      wants.html { render 'show' }
    end
  end

  def public_show
    object = end_of_association_chain.find_by_public_id!(params[:public_id])

    respond_with(object) do |wants|
      wants.html { render 'show' }
    end
  end

  protected

  #
  # Users can access the `show` action for a cart even if they are not
  # logged in.  To get around the issue the `authority` plugin has testing
  # permissions against nil, populate the current user in this case with
  # an empty new user.
  #
  # NOTE this is quite hacky and can potentially cause ripples throughout
  # wherever `current_user` is checked against, e.g. this techically means
  # that `user_logged_in?` even though there is no real current user.
  #
  def current_user
    user = super
    user ||= User.new if 'show' == params[:action]
    user
  end

  #
  # Resource is hooked into to handle requests for the current user's
  # pending cart, (at "/cart") This is *in addtion* to the scoping based
  # on role.  If an `id` is not found in the params, it is assumed to be
  # a `pending_cart` request and the cart is looked up for the current
  # user as such.  This *will not* create a cart if one does not exist,
  # but will `build` an unpersisted one (though the view will essentially
  # be "Your cart is empty")
  #
  def resource
    @cart ||= if params[:id]
      super
    elsif !current_user.is_admin?
      scoped = current_user.meta.pending_carts
      scoped.first || scoped.build
    end

    raise ActiveRecord::RecordNotFound unless @cart

    @cart
  end


  #
  # If a mill or buyer is looking at this page, their scope is restricted
  # based on their role.  See the filters below:
  #
  def begin_of_association_chain
    unless current_user.is_admin?
      current_user.meta
    end
  end

  #
  # Mills filter out carts that are in the hands of the buyer or
  # in a pending state
  #
  def collection_filter_mill_carts(object)
    if current_user.is_mill?
      object = object.not_state(:buyer_build, :pending)
    end

    object
  end

  #
  # Buyers filter out all states that are not "ordered", only seeing
  # submitted carts in the list.
  #
  def collection_filter_buyer_carts(object)
    if current_user.is_buyer?
      object = object.state(:ordered, :closed)
    end

    object
  end
end
