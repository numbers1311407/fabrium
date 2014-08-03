module CartRepresenter
  include Roar::Representer::JSON

  property :public_id, as: :id
  property :fabric_variant_ids, as: :variant_ids
end
