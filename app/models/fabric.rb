class Fabric < ActiveRecord::Base
  include Fabrics::Prices
  include Fabrics::Properties
  include Fabrics::Weight

  belongs_to :mill

  has_many :fabric_variants

  def self.calculate_color_deltas(lab)
    joins("INNER JOIN #{FabricVariant.color_delta_subselect(lab).to_sql} ON fabric_variants.fabric_id = fabrics.id")
  end
end
