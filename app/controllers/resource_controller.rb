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
  has_scope :per, default: 50
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
    return unless collection.total_pages > 1
    last_page = collection.current_page == collection.total_pages
    first_page = collection.current_page == 1

    links = {}
    links[:first] = 1 if !first_page
    links[:prev] = collection.current_page unless first_page
    links[:next] = collection.current_page unless last_page
    links[:last] = collection.total_pages unless last_page

    pagination_links = []
    links.each do |link, page|
      query = params.merge(page: page)
      query.delete(:page) if (1 == query[:page]) 
      pagination_links << "<#{collection_url(query)}>; rel=\"#{link}\""
    end

    headers['Link'] = pagination_links.join(",")
  end
end
