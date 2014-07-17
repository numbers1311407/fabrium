class Fabric < ActiveRecord::Base
  include Authority::Abilities

  include Fabrics::Prices
  include Fabrics::Properties
  include Fabrics::Weight

  validates :width, numericality: { greater_than: 0 }

  belongs_to :mill
  has_many :fabric_variants
end
