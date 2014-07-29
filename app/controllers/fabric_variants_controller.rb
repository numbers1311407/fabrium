class FabricVariantsController < ResourceController

  # During the create process, fabric variants are created without
  # a parent fabric.  They are cleaned up at a later time, but it's
  # important that they are never shown publicly as orphans
  add_collection_filter_scope :collection_filter_orphans

  # In a normal search, only the *first* variant of each fabric should
  # be returned, *unless* the search is by color, in which case all
  # matching variants for each fabric are shown.
  add_collection_filter_scope :collection_filter_primary_variant

  # always includes
  add_collection_filter_scope :collection_filter_includes

  ##
  # Scopes
  #

  # TODO the default scope, unless color is specified, will only display
  # the FIRST swatch for each fabric

  has_scope :near_color, as: :color do |controller, scope, value|
    # The 2nd param for `near_color` is the acceptable delta.  It
    # will likely be necessary to tweak this for sane search results.
    scope.near_color(value, 50)
  end

  has_scope :weight_range_or_min, as: :weight_min do |controller, scope, value|
    max = controller.params[:weight_max] || Float::INFINITY
    scope.weight (value.to_f)..(max.to_f), controller.params[:weight_units]
  end

  has_scope :weight_max, if: 'params[:weight_min].blank?' do |controller, scope, value|
    scope.weight -Float::INFINITY..(value.to_f), controller.params[:weight_units]
  end

  has_scope :category
  has_scope :dye_method
  has_scope :tags
  has_scope :material

  has_scope :in_stock
  has_scope :favorites, type: :boolean do |controller, scope, value|
    scope.favorites(current_user)
  end

  has_scope :mills, default: 'user' do |controller, scope, value|
    is_default = 'user' == value
    user = controller.current_user

    case user.meta_type.human
    when 'mill'
      # ignore `value`, mill always sees their own fabrics
      scope.mills(user.meta.id)
    when 'admin'
      # ignore 'user' default value & only scope to mills if param 
      # is passed
      is_default ? scope : scope.mills(value)
    when 'buyer'
      # buyers only see fabrics from active mills
      # TODO this should simply be in the collection filter
      scope = scope.active_mills

      # if 'user' default value is passed, and the user has preferred
      # mills, restrict to those preferred mills
      if is_default
        preferred = user.meta.preferred_mills
        preferred.present? ? scope.mills(preferred) : scope
      # otherwise scope to the value
      else
        scope.mills(value)
      end
    else
      # there are no other user types, but...
      scope
    end
  end

  has_scope :not_mills, default: 'user' do |controller, scope, value|
    is_default = 'user' == value
    user = controller.current_user

    case user.meta_type.human
    when 'mill'
      # ignore this scope for mill users, they always see their own
      # fabrics (see `mills` scope above`
      scope
    when 'admin'
      # ignore the default scope for admins
      is_default ? scope : scope.not_mills(value)
    else
      # for buyers, if the default value of user is passed, scope
      # the search by the buyer's ignored mills list if it exists,
      if is_default
        blocked = user.meta.blocked_mills
        blocked.present? ? scope.not_mills(blocked) : scope
      # otherwise scope to the value
      else
        scope.not_mills(value)
      end
    end
  end

  has_scope :fabrium_number
  has_scope :item_number
  has_scope :country
  has_scope :price
  has_scope :sample_lead_time
  has_scope :bulk_lead_time
  has_scope :sample_minimum
  has_scope :bulk_minimum

  permit_params [
    :image, 
    :retained_image, 
    :color, 
    :image_crop, 
    :item_number, 
    :in_stock
  ]

  # Renders the "preview" IFRAME form within the fabric variants upload
  # form which allows for async uploads of images without Ajax.  This
  # makes use of the dragonly image caching mechanism to store the image
  # on the server side and reference the "retained" version while working
  # with an unsaved record.
  def preview
    if params[:image].present?
      app = Dragonfly.app
      uid = app.store(params[:image].tempfile)
      @image = app.fetch(uid)
      attrs = {uid: uid}

      if @image
        attrs.merge!({ name: params[:image].original_filename })
        @retained_image = Dragonfly::Serializer.json_b64_encode(attrs)
      end
    end

    render layout: false
  end

  protected

  # redirect back to our parent after commit (this is typically a non-
  # issue since the fabric variants are managed on the parent fabric, not
  # on their own pages)
  def after_commit_redirect_path
    resource.fabric ? edit_fabric_path(resource.fabric) : fabrics_path
  end

  def collection_filter_orphans(object)
    object.orphans(false)
  end

  def collection_filter_primary_variant(object)
    params[:color] ? object : object.primary
  end

  def collection_filter_includes(object)
    object.includes(:fabric)
  end
end
