class FabricVariant < ActiveRecord::Base
  belongs_to :fabric

  def self.calculate_color_deltas(lab)
    from(color_delta_subselect(lab))
  end

  def self.color_delta_subselect(lab)
    delta = sanitize_sql_array([
      "(|/((lab[1]-?)^2+(lab[2]-?)^2+(lab[3]-?)^2)) delta", *lab
    ])
    select("*, #{delta}").as("fabric_variants")
  end

  # NOTE fabrium_id will need to auto sequence based contextually
end
