class FabricsController < ResourceController
  add_collection_filter_scope :collection_filter_includes

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
end
