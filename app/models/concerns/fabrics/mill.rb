module Fabrics
  module Mill
    extend ActiveSupport::Concern

    included do
      belongs_to :mill

      scope :mills, ->(value, options={}) {
        options[:not] ? where.not(mill: value) : where(mill: value)
      }

      scope :not_mills, ->(value) {
        mills(value, not: true)
      }

      scope :active_mills, -> {
        joins(:mill).merge(::Mill.active)
      }
    end
  end
end

