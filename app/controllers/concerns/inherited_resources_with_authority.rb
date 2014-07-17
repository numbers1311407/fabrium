module Concerns
  module InheritedResourcesWithAuthority
    extend ActiveSupport::Concern

    included do
      helper_method :auth_resource
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
      end

      def authorize_auth_resource
        authorize_action_for(auth_resource)
      end

  end
end
