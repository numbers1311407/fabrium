class Mill < ActiveRecord::Base
  has_many :fabrics
  belongs_to :user
  has_many :users
end
