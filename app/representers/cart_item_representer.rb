module CartItemRepresenter 
  include Roar::Representer::JSON

  property :id
  property :fabric_variant_id
  property :notes
  property :sample_yardage
  property :tracking_number
  property :state
end
