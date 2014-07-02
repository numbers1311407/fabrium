class ResourceController < InheritedResources::Base
  respond_to :json

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

  # This method can be overridden with `super` to further filter the
  # raw collection scope (pagination, etc)
  def apply_collection_filter_scopes(object)
    object
  end

  def collection
    get_collection_ivar || begin
      c = apply_collection_filter_scopes(end_of_association_chain)
      if defined?(ActiveRecord::DeprecatedFinders)
        # ActiveRecord::Base#scoped and ActiveRecord::Relation#all
        # are deprecated in Rails 4.  If it's a relation just use
        # it, otherwise use .all to get a relation.
        set_collection_ivar(c.is_a?(ActiveRecord::Relation) ? c : c.all)
      else
        set_collection_ivar(c.respond_to?(:scoped) ? c.scoped : c.all)
      end
    end
  end
end
