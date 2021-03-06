class ProcessOrderJob
  include SuckerPunch::Job

  def later(sec, *args)
    after(sec) { perform(*args) }
  end

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


  def transition_to_closed(cart_id)
    cart = Cart.find(cart_id)

    # if this is a subcart and there are no carts in the "open" state,
    # set the parent to closed
    if cart.subcart? && cart.siblings.not_state(:closed).none?
      cart.parent.update(state: :closed)
    end

    if cart.cart_items.any? && user = cart.buyer.try(:user)
      mailer = cart.cart_items.shipped.any? ? :order_shipped : :order_refused
      AppMailer.send(mailer, cart.parent || cart, user, cart.mill).deliver
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
      subcarts.each do |subcart|
        if subcart.save
          users = subcart.mill.users.wants_email
          AppMailer.order_received(subcart, users).deliver unless users.none?
        end
      end

    # If no subcarts are created it means that all the cart items belong
    # to this mill.  Rather than creating a subcart, just assign the
    # mill to this cart
    else
      mill = cart_items.first.mill
      cart.update_attribute(:mill, mill)
      users = mill.users.wants_email
      AppMailer.order_received(cart, users).deliver unless users.none?
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
