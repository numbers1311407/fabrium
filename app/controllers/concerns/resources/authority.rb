module Resources
  module Authority
    extend ActiveSupport::Concern

    included do
      helper_method :auth_resource

      # NOTE the controller only authorizes in a filter on the `index`
      # action, allowing the authorization in other actions to happen
      # at the resource level.  This authorization happens on an instance
      # of the resource, typically the equivalent of `build_resource`.
      # To change the object that is subject to authorization, overwrite
      # `auth_resource`
      before_filter :authorize_auth_resource, only: :index
      
      alias_method_chain :resource, :authority
      alias_method_chain :build_resource, :authority
      alias_method_chain :update_resource, :authority
    end

    protected

      def resource_with_authority
        object = resource_without_authority
        authorize_action_for(object)
        object
      end

      def build_resource_with_authority
        object = build_resource_without_authority
        authorize_action_for(object)
        object
      end

      def update_resource_with_authority object, attributes
        object.assign_attributes(*attributes)
        authorize_action_for(object)
        object.save
      end

      def auth_resource
        @auth_resource ||= end_of_association_chain.send(method_for_build)
        Rails.logger.info(@auth_resource.inspect)
        @auth_resource
      end

      def authorize_auth_resource
        authorize_action_for(auth_resource)
      end

      # Memoize the association chain as otherwise calling it here will
      # cause scopes to be applied twice.  Typically in InheritedResources
      # end_of_association_chain is only called once, in the memoization
      # of collection or resource (meaning memoizing the object is unnecessary,
      # but doing so shouldn't cause issue)
      #
      # WARN end_of_association_chain is memoized, could this cause an issue?
      #
      def end_of_association_chain
        @end_of_association_chain ||= super
      end

  end
end
