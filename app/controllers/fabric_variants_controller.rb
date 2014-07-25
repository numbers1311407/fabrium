class FabricVariantsController < ResourceController
  prepend_before_filter :combine_property_queries

  ##
  # Scopes
  #

  # TODO the default scope, unless color is specified, will only display
  # the FIRST swatch for each fabric

  has_scope :near_color, as: :color do |controller, scope, value|
    # The 2nd param for `near_color` is the acceptable delta.  It
    # will likely be necessary to tweak this for sane search results.
    scope.near_color(value, 25)
  end

  has_scope :weight_range_or_min, as: :weight_min do |controller, scope, value|
    max = controller.params[:weight_max] || Float::INFINITY
    scope.weight (value.to_f)..(max.to_f), controller.params[:weight_units]
  end

  has_scope :weight_max, if: 'params[:weight_min].blank?' do |controller, scope, value|
    scope.weight -Float::INFINITY..(value.to_f), controller.params[:weight_units]
  end

  has_scope :properties, type: :hash

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

  def combine_property_queries
    params[:properties] = params.slice(:keywords, :fiber, :category)
    params.except!(:keywords, :fiber, :category)

    Rails.logger.error(params)
  end
end
