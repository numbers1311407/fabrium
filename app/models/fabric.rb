class Fabric < ActiveRecord::Base
  include Fabrics::Prices
  include Fabrics::Properties
  include Fabrics::Weight

  belongs_to :mill
  has_many :fabric_variants
end
