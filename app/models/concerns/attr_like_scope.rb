module AttrLikeScope
  extend ActiveSupport::Concern

  module ClassMethods
    def attr_like attr, value, options={}
      where attrs_like_conditions(Array.wrap(attr), value, options)
    end

    alias :attrs_like :attr_like

    def attr_like_scopes *attrs
      attrs.each do |attr|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          scope :#{attr}_like, ->(v) { attr_like(:#{attr}, v) }
        RUBY
      end
    end

    protected

    def attr_like_condition attr, value, options={}
      pattern = options[:pattern] || "%s%"
      arel_table[attr].matches(pattern % value)
    end

    def attrs_like_conditions attrs, value, options={}
      operation = options[:operation] || :or

      attrs.map do |attr|
        attr_like_condition(attr, value, options)
      end.reduce(&operation)
    end
  end
end
