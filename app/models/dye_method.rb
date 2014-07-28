class DyeMethod < ActiveRecord::Base
  include Authority::Abilities

  has_many :fabrics
end
