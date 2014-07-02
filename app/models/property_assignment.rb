class PropertyAssignment < ActiveRecord::Base
  belongs_to :property
  belongs_to :fabric

  delegate :name, to: :property, allow_nil: true
end
