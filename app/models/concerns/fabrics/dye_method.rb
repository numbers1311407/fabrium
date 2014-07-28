module Fabrics
  module DyeMethod
    extend ActiveSupport::Concern

    included do
      belongs_to :dye_method
      scope :dye_method, ->(v) { where(dye_method: v) }
    end
  end
end
