module Properties
  #
  # Sets up the property "kind" enum and simple scopes, stores the
  # association type option for each kind so that models that *have*
  # properties can define their associations.
  #
  module Kinds
    extend ActiveSupport::Concern

    included do
      class_attribute :kinds_options
      self.kinds_options = {}
    end

    module ClassMethods
      def define_kinds opts
        enum_opts = {}

        self.kinds_options = opts

        opts.each.with_index do |pair, i|
          kind, association = pair
          enum_opts[kind] = i

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            scope :#{kind.to_s.pluralize}, ->{ where(kind: kinds[:#{kind}]) }
          RUBY
        end

        enum(kind: enum_opts)
      end

      def get_kind_association_type(kind)
        kinds_options[kind.to_sym] || kinds_options[kind]
      end
    end
  end
end
