class FabricVariantsController < ResourceController

  # During the create process, fabric variants are created without
  # a parent fabric.  They are cleaned up at a later time, but it's
  # important that they are never shown publicly as orphans
  add_collection_filter_scope :collection_filter_orphans

  # In a typical search, only the *first* variant of each fabric should
  # be returned.  The exceptions to this are searching by color, exact
  # item number / fabrium id
  add_collection_filter_scope :collection_filter_primary_variant

  # Do not search archived fabrics
  add_collection_filter_scope :collection_filter_archived

  # always includes
  add_collection_filter_scope :collection_filter_includes

  # filter the scope by role
  add_collection_filter_scope :collection_filter_roles

  # block searches as defined by each mill's block list
  add_collection_filter_scope :collection_filter_blocklists

  ##
  # Scopes
  #

  has_scope :sort, default: "newest_first" do |controller, scope, value|
    case value
    when "newest_first" then scope.order(created_at: :desc)
    when "fabrium_id"   then scope.order(fabrium_id: :asc)
    when "item_number"  then scope.order(item_number: :asc)
    end
  end

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

  has_scope :price_range_or_min, as: :price_min do |controller, scope, value|
    max = controller.params[:price_max] || Float::INFINITY
    scope.weight (value.to_f)..(max.to_f), controller.params[:price_units]
  end

  has_scope :price_max, as: :price_min do |controller, scope, value|
    scope.weight -Float::INFINITY..(value.to_f), controller.params[:price_units]
  end

  has_scope :in_stock

  has_scope :favorites, type: :boolean do |controller, scope, value|
    scope.favorites(controller.current_user)
  end

  has_scope :mills do |controller, scope, value|
    is_default = 'default' == value
    user = controller.current_user

    # mill users ignore the scope, they only see their own fabrics
    if user.is_mill?
      scope

    # buyers get the special "preferred" param which scopes off
    # their preferred mills list
    elsif user.is_buyer? && 'preferred' == value 
      preferred = user.meta.preferred_mills
      preferred.present? ? scope.mills(preferred) : scope

    # otherwise scope to the value
    else
      scope.mills(value)
    end
  end

  has_scope :not_mills, default: 'default' do |controller, scope, value|
    is_default = 'default' == value
    user = controller.current_user

    # mill users ignore the scope, they only see their own fabrics
    if user.is_mill?
      scope

    # buyer users default to skipping mills from their blocked list
    elsif user.is_buyer? && is_default
      blocked = user.meta.blocked_mills
      blocked.present? ? scope.not_mills(blocked) : scope

    # otherwise scope to the passed value if something other than
    # 'default' was passed
    else
      is_default ? scope : scope.not_mills(value)
    end
  end

  has_scope :bulk_lead_time
  has_scope :bulk_minimum_quality, as: :bulk_min
  has_scope :category
  has_scope :country
  has_scope :dye_method
  has_scope :fabrium_id, as: :fid
  has_scope :item_number
  has_scope :material
  has_scope :price
  has_scope :sample_lead_time
  has_scope :sample_minimum_quality, as: :sample_min
  has_scope :tags

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
        @colors = Miro::DominantColors.new(params[:image].tempfile).to_hex
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
    non_primary_search_keys = [:color, :fid, :item_number]

    if non_primary_search_keys.any? {|key| params.has_key?(key) }
      object
    else
      object.primary
    end
  end

  def collection_filter_includes(object)
    object.includes(:fabric)
  end

  def collection_filter_roles(object)
    case current_user.meta_type.human

    # buyers only see fabrics from active mills
    when 'buyer'
      object = object.active_mills

    # mills only see their own fabrics
    when 'mill'
      object = object.mills(current_user.meta.id)
    end

    object
  end

  def collection_filter_blocklists(object)
    if current_user.is_buyer?
      object = object.merge(Mill.filter_by_domain(current_user.domain))
    end

    object
  end

  def collection_filter_archived(object)
    object.archived(false)
  end
end
