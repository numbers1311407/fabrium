class ResourceController < InheritedResources::Base
  before_filter :authenticate_user!

  include Concerns::InheritedResourcesWithAuthority
  include Concerns::PermitParams
  include Concerns::CollectionFilter
  include Concerns::Ransack

  include Roar::Rails::ControllerAdditions

  before_filter :set_pagination, only: :index

  respond_to :json

  has_scope :page, default: 1
  has_scope :per, default: 5
  has_scope :padding

  def create
    create! do |success, failure|
      success.html { redirect_to after_commit_redirect_path }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to after_commit_redirect_path }
    end
  end

  protected

  def determine_layout
    request.xhr? ? false : 'admin'
  end

  def after_commit_redirect_path
    collection_path
  end

  helper_method :maybe_resource, 
                :resource_name,
                :collection_name, 
                :resource_label

  # Helper method to maybe access the resource in views, without triggering
  # the actual resource generation
  def maybe_resource
    get_resource_ivar
  end

  def resource_name
    resource_class.model_name.human.titleize
  end

  def collection_name
    resource_class.model_name.plural.titleize
  end

  def resource_label attribute
    resource_class.human_attribute_name(attribute)
  end

  def set_pagination
    page = collection.current_page
    pages = collection.total_pages
    per_page = collection.limit_value
    total_count = collection.total_count

    headers['X-Pagination'] = {
      page: page,
      pages: pages,
      per_page: per_page,
      total_count: total_count,
      from: (page - 1) * per_page + 1,
      to: [page * per_page, total_count].min
    }.to_json
  end
end
