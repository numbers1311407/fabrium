class FabricsController < ResourceController
  custom_actions resource: [:test_item_number, :toggle_archived]
  add_collection_filter_scope :collection_filter_includes
  authority_actions toggle_archived: :update

  permit_params [
    :bulk_lead_time, 
    :bulk_minimum_quality, 
    :category_id, 
    :country,
    :dye_method_id,
    :in_stock, 
    :item_number, 
    :mill_id, 
    :price_eu_min,
    :price_eu_max,
    :price_us_min,
    :price_us_max,
    :pricing_type,
    :sample_lead_time, 
    :sample_minimum_quality, 
    :weight,
    :weight_units, 
    :width,
    :category_id,
    :dye_method_id,
    tag_ids: [],
    fabric_variants_attributes: [:id, :_destroy, :position],
    materials_attributes: [:id, :material_id, :value, :_destroy],
  ]

  before_filter :build_nested_associations, only: [:new, :edit]

  # increment view count on show
  def show
    object = resource
    object.increment!(:views_count)

    show!
  end

  def toggle_archived
    object = resource
    object.archived = !object.archived
    object.save
  end

  def test_item_number
    query = resource_params[0]
    scope = end_of_association_chain.where(query)

    # if `nid` is passed, exclude that id
    if params[:nid]
      scope = scope.where.not(id: params[:nid])
    end

    fabric = scope.first

    res = if !fabric
      true
    else
      "This fabric already exists. #{view_context.link_to "View fabric now.", edit_fabric_url(fabric)}"
    end

    render(json: res.to_json)
  end

  protected

  def after_commit_redirect_path
    params[:commit_and_redirect] ? new_resource_path : collection_path
  end

  def build_nested_associations
    object = 'new' == params[:action] ? build_resource : resource

    resource.category || resource.build_category
    resource.dye_method || resource.build_dye_method
  end

  def collection_filter_includes(object)
    object.
      includes(:fabric_variants).
      includes(:category).
      includes(:mill).
      includes(:dye_method)
  end

  def begin_of_association_chain
    if current_user && current_user.is_mill?
      current_user.meta
    end
  end
end
