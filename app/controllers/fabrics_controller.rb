class FabricsController < ResourceController
  custom_actions resource: [:test_item_number, :toggle_archived]
  add_collection_filter_scope :collection_filter_includes
  authority_actions toggle_archived: :update

  skip_before_filter :authenticate_user!, if: :skip_authenticate_on_show?

  permit_params [
    :archived,
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

  after_filter :set_last_committed_mill, only: [:update, :create]

  # increment view count on show
  def show
    object = resource
    object.increment!(:views_count)

    show!
  end

  def new
    new! do |wants|
      wants.html { render layout: !request.xhr? }
    end
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

  def set_last_committed_mill
    if resource.persisted? && current_user.is_admin?
      session[:last_created_fabric_mill] = resource.mill_id
    end
  end

  def after_commit_redirect_path
    params[:commit_and_redirect] ? new_resource_path : edit_resource_path 
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
    if public_cart
      public_cart
    elsif current_user && current_user.is_mill?
      current_user.meta
    end
  end

  def build_resource
    @fabric ||= super.tap do |fabric|

      if current_user.is_admin? && fabric.mill.blank? && session[:last_created_fabric_mill]
        fabric.mill_id = session[:last_created_fabric_mill]
      end

      if mill = fabric.mill

        fabric.country = fabric.country.presence || mill.country

        if fabric.sample_lead_time.blank? || fabric.sample_lead_time.zero? 
          fabric.sample_lead_time = mill.sample_lead_time
        end

        if fabric.bulk_lead_time.blank? || fabric.bulk_lead_time.zero?
          fabric.bulk_lead_time = mill.bulk_lead_time
        end

        if fabric.sample_minimum_quality.blank? || fabric.sample_minimum_quality.zero?
          fabric.sample_minimum_quality = mill.sample_minimum_quality
        end

        if fabric.bulk_minimum_quality.blank? || fabric.bulk_minimum_quality.zero?
          fabric.bulk_minimum_quality = mill.bulk_minimum_quality
        end
      end
    end
  end

  def resource
    object = resource_without_authority
    authorize_action_for(object) unless public_cart
    object
  end

  def public_cart
    return nil if false == @public_cart
    @public_cart ||= params[:public_id].present? && Cart.find_by!(public_id: params[:public_id]) || false
  end

  def skip_authenticate_on_show?
    'show' == action_name && public_cart.present?
  end
end
