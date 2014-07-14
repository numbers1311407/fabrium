class Buyer < ActiveRecord::Base
  has_one :user
end
