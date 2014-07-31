module UserRepresenter 
  include Roar::Representer::JSON

  property :id  
  property :email

  property :meta_type
  property :favorite_fabric_variant_ids
end
