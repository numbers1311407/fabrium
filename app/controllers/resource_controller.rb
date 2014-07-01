class ResourceController < InheritedResources::Base
  has_scope :page, default: 1
  has_scope :per, default: 50
  has_scope :padding

  protected

  # Helper method to maybe access the resource in views, without triggering
  # the actual resource generation
  def maybe_resource
    get_resource_ivar
  end

  helper_method :maybe_resource
end
