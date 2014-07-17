class Mill < ActiveRecord::Base
  include Authority::Abilities

  has_many :fabrics
  belongs_to :user
  has_many :users
end
