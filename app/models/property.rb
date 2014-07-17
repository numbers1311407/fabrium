class Property < ActiveRecord::Base
  enum kind: {
    keyword: 0,
    category: 1,
    fiber: 2,
    dye_method: 3
  }

  KindAssociationMap = {
    keyword: :has_many,
    category: :has_one,
    fiber: :has_many,
    dye_method: :has_one
  }

  scope :keywords, -> { where(kind: Property.kinds[:keyword]) }
  scope :categories, -> { where(kind: Property.kinds[:category]) }
  scope :fibers, -> { where(kind: Property.kinds[:fiber]) }
  scope :dye_methods, -> { where(kind: Property.kinds[:dye_method]) }

  scope :name_like, ->(v) { where(arel_table[:name].matches(v)) }

  has_many :property_assignments, dependent: :destroy, inverse_of: :property
  has_many :fabrics, through: :property_assignments
end
