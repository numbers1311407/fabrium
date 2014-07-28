class Category < ActiveRecord::Base
  include Authority::Abilities

  has_many :fabrics
end
