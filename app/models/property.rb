class Property < ActiveRecord::Base
  enum kind: {
    keyword: 0,
    category: 1,
    fiber: 2,
    dye_method: 3
  }

  has_many :property_assignments, dependent: :destroy
  has_many :fabrics, through: :property_assignments
end
