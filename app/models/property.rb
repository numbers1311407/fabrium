class Property < ActiveRecord::Base
  include Properties::Kinds

  define_kinds({
    keyword: :has_many, 
    category: :has_one, 
    fiber: :has_many, 
    dye_method: :has_one
  })

  scope :name_like, ->(v) { where(arel_table[:name].matches(v)) }

  has_many :property_assignments, dependent: :destroy, inverse_of: :property
  has_many :fabrics, through: :property_assignments
end
