module Fabrics
  module Category
    extend ActiveSupport::Concern

    included do
      belongs_to :category
      scope :category, ->(v) { where(category: v) }
    end
  end
end
