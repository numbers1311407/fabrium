class Material < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer = FabriumResourceAuthorizer

  has_many :material_assignments, dependent: :delete_all
  has_many :materials, through: :material_assignments
end
