class UserMill < ActiveRecord::Base
  belongs_to :mill
  belongs_to :user
end
