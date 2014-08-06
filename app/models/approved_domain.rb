class ApprovedDomain < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer = FabriumResourceAuthorizer

  enum entity: [:buyer, :mill]
  validates_format_of :name, with: /\A(.*)\.(.*)\z/

  scope :for_buyer, -> { where(entity: entities[:buyer]) }
  scope :for_mill, -> { where(entity: entities[:mill]) }
end
