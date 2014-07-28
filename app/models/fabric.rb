class Fabric < ActiveRecord::Base
  include Authority::Abilities

  include Fabrics::Prices
  include Fabrics::Category
  include Fabrics::DyeMethod
  include Fabrics::Tags
  include Fabrics::Materials
  include Fabrics::Variants
  include Fabrics::Category
  include Fabrics::Weight

  validates :width, numericality: { greater_than: 0 }

  belongs_to :mill
end
