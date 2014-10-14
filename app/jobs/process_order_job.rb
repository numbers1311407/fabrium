class ProcessOrderJob
  include SuckerPunch::Job

  def perform(job, *args)
    ActiveRecord::Base.connection_pool.with_connection do
      send(job, *args)
    end
  end

  def process_pending_user_carts(user_id)
    user = User.find(user_id)
    user.meta.carts.state(:pending).each do |cart|
      cart.state = Cart.states[:ordered]
      cart.save
    end
  end

  def transition_to_ordered(cart_id)
    cart = Cart.find(cart_id)

    cart_items = cart.cart_items.includes(:fabric_variant)

    # this should not happen as it's validated against when this cart
    # becomes pending, but...
    return if cart_items.empty?

    subcarts = cart.build_subcarts

    # If subcarts are created, it means that the cart items belong to
    # more than one mill.  Subcarts are clones used to split up carts
    # so mills can each manage their own cart object
    if subcarts.length > 1
      subcarts.each(&:save)

    # If no subcarts are created it means that all the cart items belong
    # to this mill.  Rather than creating a subcart, just assign the
    # mill to this cart
    else
      cart.update(mill: cart_items.first.mill)
    end

    # Update the orders_count for the ordered fabrics, which may be
    # multiple times per if more than one FabricVariant for a Fabric 
    # was ordered
    increments = {}
    cart_items.each do |item|
      key = item.fabric_variant.fabric_id
      increments[key] ||= 0
      increments[key] += 1
    end

    increments.each do |key, value|
      Fabric.update_counters key, orders_count: value
    end
  end
end
