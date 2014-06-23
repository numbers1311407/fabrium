class PropertyAssignment < ActiveRecord::Base
  belongs_to :property
  belongs_to :fabric

  # def property_type=(sType)
  #   super(sType.to_s.classify.constantize.base_class.to_s)
  # end
end
