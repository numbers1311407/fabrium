class FabricVariantsController < ResourceController
  has_scope :near_color, as: :color
end
