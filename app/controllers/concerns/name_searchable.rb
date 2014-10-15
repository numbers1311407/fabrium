module NameSearchable
  extend ActiveSupport::Concern

  included do
    has_scope :name do |controller, scope, value|
      scope.attr_like(:name, value, pattern: "%%%s%")
    end
  end
end
