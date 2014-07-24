class FabricVariantsController < ResourceController
  has_scope :near_color, as: :color

  permit_params [
    :image, 
    :retained_image, 
    :color, 
    :image_crop, 
    :item_number, 
    :in_stock
  ]

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

  def after_commit_redirect_path
    resource.fabric ? edit_fabric_path(resource.fabric) : fabrics_path
  end
end
