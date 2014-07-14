module Users
  module BelongsToMeta
    extend ActiveSupport::Concern

    included do
      belongs_to :meta, polymorphic: true
      validates :meta, presence: true
      accepts_nested_attributes_for :meta, allow_destroy: false

      delegate :name, to: :meta, prefix: true
    end

    # Give meta_type a little more functionality via an activesupport
    # style inquirer
    def meta_type
      TypeInquirer.new(read_attribute(:meta_type) || '')
    end

    # Necessary to make accepts_nested_attributes work with a polymorphic
    # belongs_to.  Seems to be ok...
    def build_meta(attributes={})
      if self.meta
        self.meta.assign_attributes(attributes)
      elsif meta_type && (klass = meta_type.constantize.base_class)
        self.meta = klass.new(attributes)
      end

      self.meta
    rescue
      Rollbar.report_exception($!)
      nil
    end

    protected

    module ClassMethods
      def define_meta_types *types
        delegate *types.map {|t| :"#{t}?" }, to: :meta_type

        types.map(&:to_s).each do |t|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            scope :#{t.pluralize}, ->{ where(meta_type: "#{t.classify}") }
          RUBY
        end
      end
    end

    class TypeInquirer < String
      def human
        underscore
      end

      private

      def respond_to_missing?(method_name, include_private = false)
        method_name[-1] == '?'
      end

      def method_missing(method_name, *arguments)
        if method_name[-1] == '?'
          self.human == method_name[0..-2]
        else
          super
        end
      end
    end
  end
end
