class Category < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer = FabriumResourceAuthorizer

  has_many :fabrics
end
