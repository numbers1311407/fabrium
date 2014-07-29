class Mill < ActiveRecord::Base
  include Authority::Abilities

  scope :active, ->{ where(active: true) }

  has_many :fabrics
  belongs_to :user
  has_many :users
end
