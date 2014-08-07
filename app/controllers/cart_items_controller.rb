class CartItemsController < ResourceController
  belongs_to :cart
  defaults finder: :find_by_fabric_variant_id!

  permit_params [
    :fabric_variant_id,
    :notes,
    :sample_yardage,
    :tracking_number
  ]

  respond_to :js, only: :update

  def update
    object = resource

    if params[:state_shipped]
      object.state = :shipped
    elsif params[:state_refused]
      object.state = :refused
    end

    update!
  end

  protected

  # Rather hacky way of hijacking the parent lookup from the normal
  # belongs_to stack.  This is how posts to the current user's pending
  # cart are handled, e.g. a POST to `/cart/items` which would add
  # a cart item to the current user's pending cart and create that cart
  # first if necessary
  def evaluate_parent(*args)
    return super if params[:cart_id]
    cart = get_pending_cart
    raise ActiveRecord::RecordNotFound unless cart && cart.persisted?
    cart
  end

  def resource_request_name
    :item
  end

  def get_pending_cart
    # admins do not have a cart
    return nil if current_user.is_admin?

    # get the scope for the pending carts of the current user
    scope = current_user.meta.pending_carts

    # Return the first one if it exists (there should be only one)
    # If it does not exist and this is a `create` request, make a new
    # pending cart for the meta entity
    scope.first || if 'create' == params[:action]
      scope.create
    end
  end
end
