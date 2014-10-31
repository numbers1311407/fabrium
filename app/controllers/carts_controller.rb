class CartsController < ResourceController

  custom_actions resource: [:pending_cart]
  authority_actions pending_cart: :read

  skip_before_filter :authenticate_user!, only: [:public_show]

  add_collection_filter_scope :collection_filter_mill_carts
  add_collection_filter_scope :collection_filter_buyer_carts

  permit_params [
    :buyer_email,
    :buyer_email_confirmation,
    :tracking_number, 
    cart_items_attributes: [
      :id, 
      :notes, 
      :sample_yardage, 
      :request_yardage,
      :fabric_variant_id,
      :state
    ]
  ]

  has_scope :buyer do |controller, scope, value|
    scope.where(buyer_id: value)
  end

  has_scope :mill do |controller, scope, value|
    scope.where(mill_id: value)
  end

  has_scope :scope do |controller, scope, value|
    user = controller.current_user

    case value
    when 'buyer'
      if user.is_mill?
        scope = scope.state(:buyer_build, :buyer_unclaimed)
      end
    when 'active'
      if user.is_mill?
        scope = scope.mill_build
      elsif user.is_buyer?
        scope = scope.buyer_build
      end
    when 'ordered', 'mill_build', 'buyer_build', 'closed'
      scope = scope.send(value)
    end

    scope
  end

  #
  # GET /cart
  #
  def pending_cart
    object = resource

    respond_with(object) do |wants|
      wants.html { render 'edit' }
    end
  end


  #
  # Most other resources redirct HTML show requests to edit (no show view)
  # Cart has several show and edit views based on the state and role of the
  # viewer, but always renders the "edit" template.
  #
  def show
    # if the cart isn't publicly viewed yet and the viewer is the cart's
    # buyer's user, set public_viewed
    if !resource.public_viewed && resource.buyer.try(:user) == current_user
      resource.update_column(:public_viewed, Time.now)
    end

    show! do |wants|
      wants.html { render 'edit' }
    end
  end


  #
  # The state based messages here are probably a little too complex for
  # the basic responder interpolation options (unless the messages were `"%{message}").
  # Let's just send our own flash.
  #
  def update
    super(flash_update_messages)
  end


  def index
    index! do |format|
      format.html do
        if params[:scope]
          session[:carts_scope] = params[:scope]
        else
          session.delete(:carts_scope)
        end

        # if !request.xhr? && params[:scope].blank? && current_user.is_mill?
        #   redirect_to collection_path(scope: 'ordered')
        # end
      end
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

    unless object.public_viewed
      object.update_column(:public_viewed, Time.now.utc)
    end

    # If the object is not public (basically if it has a buyer attached
    # already) then this will just redirect to the authenticated URL of
    # the object.
    #
    # This handles the situation where a buyer who already exists visits
    # the URL.  If they own the cart they are just redirect to its auth'd
    # URL, if they do not, they will 403 on it.
    #
    unless object.public?
      redirect_to object
      return
    end

    # store the location so we'll return here after signing in directly
    # (without hitting some other auth'd URL that would reset the stored
    # location)
    store_location_for(:user, public_cart_url(object.public_id))

    # store the id of the cart which will be attached to a buyer after
    # sign up
    session[:public_cart_id] = object.id

    # Store the mill of the public cart.  This will be set as the inviter
    # of the resulting user, if the cart invite results in a user registration
    # (which is hopefully that of a buyer and not another mill, though there's
    # nothing stopping that from happening currently)
    session[:public_cart_mill] = object.mill.try(:id)

    respond_with(object)
  end

  protected

  def flash_update_messages
    resource_state = resource.state
    messages = {}

    %w(alert notice).each do |state|
      defaults = []
      defaults << :"cart_state_flash.#{resource_state}.#{state}"
      defaults << :"cart_state_flash.default.#{state}"

      messages[state.to_sym] = I18n.t(defaults.shift, default: defaults)
    end

    messages
  end

  def after_commit_redirect_path
    collection_path
  end

  def scope_options
    if current_user.is_admin?
      %w(buyer_build mill_build ordered closed)
    elsif current_user.is_mill?
      %w(buyer ordered closed)
    else
      %w(active ordered closed)
    end
  end
  helper_method :scope_options

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


  # for mills/buyers, auth for index read on a new pending cart
  def auth_resource
    if current_user.is_mill? || current_user.is_buyer?
      current_user.meta.pending_carts.new
    else
      super
    end
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
    object.save.tap do |result|
      object.state = object.state_was unless result
    end
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
  # Mills only see carts belonging to them, meaning they'll only see
  # carts they created (which by definition cannot include items from
  # other mills), "subcarts" which have been split off of buyer created
  # carts, and buyer created carts which have been assigned to the mill
  # because it is the sole mill responsible for the items.  This should
  # naturally exclude buyer carts that have fabrics in them for multiple
  # mills.
  #
  # Mills should also not see their "current" cart, which should be
  # edited at /cart (though it is technically available at its full
  # resource URI)
  #
  def collection_filter_mill_carts(object)
    if current_user.is_mill?
      object = object.not_state(:mill_build, :pending)
    end

    object
  end

  #
  # Buyers see the carts they're currently building (buyer_build) and
  # carts that are past the "order" stage.
  #
  # Buyers do not see "subcarts" which were split up for mills, but 
  # rather only the full carts.
  #
  # Buyers should also not see their "current" cart, which should be
  # edited at /cart (though it is technically available at its full
  # resource URI)
  #
  def collection_filter_buyer_carts(object)
    if current_user.is_buyer?
      object = object.state(:buyer_build, :ordered, :closed)
      object = object.exclude_subcarts

      # TODO this should be a scope "not the pending cart"
      ids = current_user.meta.pending_carts.ids
      object = object.where.not(id: ids)
    end

    object
  end

  def after_commit_redirect_path
    resource_url
    # args = {}
    # args[:scope] = session[:carts_scope] if session[:carts_scope]
    # collection_url(args)
  end
end
