class Fabric < ActiveRecord::Base
  include Fabrics::Prices
  include Fabrics::Properties
  include Fabrics::Weight

  belongs_to :mill

  has_many :fabric_variants

  def self.calculate_color_deltas(lab)
    joins("INNER JOIN #{FabricVariant.color_delta_subselect(lab).to_sql} ON fabric_variants.fabric_id = fabrics.id")
  end

  def self.near_color(color, max_delta=nil)
    scoped = calculate_color_deltas(color).order("fabric_variants.delta ASC")
    scoped = scoped.where(["fabric_variants.delta < ?", max_delta]) if max_delta.present?
    scoped
  end
end
