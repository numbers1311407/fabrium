class Buyer < ActiveRecord::Base
  has_one :user

  def blocked_mills
    [2]
  end

  def preferred_mills
    [1]
  end
end
