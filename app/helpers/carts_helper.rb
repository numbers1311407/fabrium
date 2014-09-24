module CartsHelper
  def cart_button_label(cart)
    I18n.t(:"helpers.submit.cart.states.#{cart.state}")
  end

  def translate_cart_state(state)
    translate_state(state, :cart)
  end

  def translate_cart_item_state(state)
    translate_state(state, :cart_item)
  end

  def translate_state(state, type)
    defaults = []
    defaults << :"states.#{type}.#{current_user.meta_type.human}.#{state}" if current_user
    defaults << :"states.#{type}.#{state}"
    defaults << state.humanize

    out = translate(defaults.shift, default: defaults)
  end

  # TODO This needs a lot of work
  def humanize_creator_type(resource)
    if current_user.is_buyer? && resource.buyer_created?
      t('labels.my_carts')
    elsif current_user.is_mill? && resource.mill_created?
      t('labels.my_carts')
    else
      resource.creator.class.name
    end
  end

  def pending_cart_size
    meta = current_user.meta
    if meta.respond_to?(:pending_carts) && (cart = meta.pending_carts.first)
      cart.cart_items.count
    else
      0
    end
  end

  def carts_scope_select_tag
    scope_select_tag :carts
  end

  def carts_buyer_select_tag
    name = :buyer
    collection = Buyer.select(:id, :first_name, :last_name).limit(10).order(:first_name)
    endpoint = buyers_path(:json)
    select_options = collection.map {|o| [o.name, o.id] }

    association_select_tag(name, select_options, endpoint)
  end

  def carts_mill_select_tag
    name = :mill
    collection = Mill.select(:id, :name).limit(10).order(:name)
    endpoint = mills_path(:json)
    select_options = collection.map {|o| [o.name, o.id] }

    association_select_tag(name, select_options, endpoint)
  end
end


