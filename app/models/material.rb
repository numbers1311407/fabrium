class Material < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer = FabriumResourceAuthorizer

  has_many :material_assignments
  has_many :materials, through: :material_assignments
end
