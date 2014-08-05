class CartItemsController < ResourceController
  belongs_to :cart, finder: :find_by_public_id
  defaults finder: :find_by_fabric_variant_id!, instance_name: :item, route_instance_name: :item

  permit_params [
    :fabric_variant_id
  ]

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
