class CartsController < ResourceController
  custom_actions resource: [:pending_cart]
  authority_actions pending_cart: :read

  skip_before_filter :authenticate_user!, :only => [:public_show]

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
      wants.html { render 'edit' }
    end
  end

  # GET /carts/<public id>/pub
  #
  # This is a public route that a member is sent via a token.  It is
  # only available while the resource has no attached member.  Afterward,
  # the public route will redirect to the authenticated route and require
  # a login.
  #
  def public_show
    object = resource

    unless object.public?
      redirect_to object
      return
    end

    respond_with(object) do |wants|
      wants.html { render 'edit' }
    end
  end

  protected


  def resource
    # If this is a `public_show` request, skip the authority action and
    # just look up the cart by public id
    @cart ||= if 'public_show' == params[:action]
      end_of_association_chain.find_by!(public_id: params[:public_id])

    # else if there's an ID param just look up the resource as normal
    elsif params[:id]
      super

    # And if there is not, and this type of user can have a pending cart
    # look up the current cart or build an unsaved one.
    # Currently running the auth action here after the fact for consistency,
    # though it's probably unnecessary
    elsif !current_user.is_admin?
      scoped = current_user.meta.pending_carts
      object = scoped.first || scoped.build
      authorize_action_for(object) if object
      object
    end

    # Finally if no cart was found here, raise.  This will happen
    # before we reach this point in most cases.
    raise ActiveRecord::RecordNotFound unless @cart

    @cart
  end


  # Before update, "bump" the state of the cart.  This is how the cart
  # progresses from state to state via the control.  While the cart items
  # are edited separately at multiple stages, the cart itself is only
  # submitted when changing states.
  #
  # Mill Build -> Buyer Build -> Ordered
  #
  def update_resource(object, attributes)
    object.attributes = attributes[0]
    object.bump_state
    object.save
  end


  #
  # If a mill or buyer is looking at this page, their scope is scoped
  # to their personal carts.
  #
  # It is further restricted on the index routes by the filters below.
  #
  def begin_of_association_chain
    if current_user && !current_user.is_admin?
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
      object = object.state(:buyer_build, :ordered, :closed)
    end

    object
  end
end
