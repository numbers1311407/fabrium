module Concerns
  #
  # Simple module to simplify the process of permitting params inside an
  # InheritedResources controller.
  #
  # Simplifies this:
  # 
  #     def permitted_params
  #       params.permit(instance_name: %w(each param to permit))
  #     end
  #
  # To this:
  #
  #     permit_params :each, :param, :to, :permit
  #
  # Note that the simple multiple-param-as-array syntax will only work
  # if the permitted params do not need to be nested.  In the case that
  # they do, they must be passed as an array.
  #
  #     permit_params [:foo, bar_association_ids: []]
  #
  module PermitParams
    extend ActiveSupport::Concern

    included do
      class_attribute :_permitted_params
      self._permitted_params = []
    end

    protected

    def permitted_params(parameters=nil)
      options = {}
      options[resource_instance_name] = _permitted_params
      (parameters || params).permit(options)
    end

    module ClassMethods
      def permit_params(*parameters)
        self._permitted_params = if parameters[0].is_a?(Array)
          parameters[0]
        else
          parameters.flatten.map(&:to_sym)
        end
      end
    end
  end
end
