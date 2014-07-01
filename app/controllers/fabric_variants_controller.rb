class FabricVariantsController < ResourceController
  respond_to :json
  has_scope :near_color, as: :color
end
