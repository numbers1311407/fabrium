class FabricVariant < ActiveRecord::Base
  include FabricVariants::Color
  belongs_to :fabric
end
