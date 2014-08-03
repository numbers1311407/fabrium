module Resources
  module CollectionFilter
    extend ActiveSupport::Concern

    included do
      class_attribute :collection_filter_scopes
      self.collection_filter_scopes = []
    end

    module ClassMethods
      def add_collection_filter_scope(scope)
        # Note this is `+=` instead of `<<` to force creation of a new array 
        # rather than appending to the parent
        self.collection_filter_scopes += [scope]
      end
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

    protected

      def apply_collection_filter_scopes(object)
        collection_filter_scopes.each do |scope|
          case scope
          when Proc
            object = instance_exec(object, &scope)
          when Symbol
            object = send(scope, object)
          else
            raise "apply_collection_filter_scopes accepts String or Proc, got #{scope}"
          end
        end

        object
      end

  end
end
