class BuyerMill < ActiveRecord::Base
  include Authority::Abilities 

  belongs_to :mill
  belongs_to :buyer

  enum relationship: [:preferred, :blocked]

  scope :preferred, -> { where(relationship: relationships[:preferred]) }
  scope :blocked, -> { where(relationship: relationships[:blocked]) }
end
