class ResourceController < InheritedResources::Base
  self.layout_name = 'admin'

  include Resources::Authority
  include Resources::PermitParams
  include Resources::CollectionFilter
  include Resources::Ransack
  include Resources::Pagination

  include Roar::Rails::ControllerAdditions

  responders :flash

  respond_to :json

  def show
    show! do |wants|
      wants.html { redirect_to edit_resource_path(resource) }
    end
  end

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

  def destroy
    destroy! do |wants|
      wants.js { head 204 }
    end
  end

  protected

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

  def resource_label attribute, object=nil
    klass = resource_class

    if object
      if object.respond_to?(:human_attribute_name)
        klass = object
      elsif object.class.respond_to?(:human_attribute_name)
        klass = object.class
      end
    end

    klass.human_attribute_name(attribute)
  end
end
