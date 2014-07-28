class Material < ActiveRecord::Base
  include Authority::Abilities

  has_many :material_assignments
  has_many :materials, through: :material_assignments
end
