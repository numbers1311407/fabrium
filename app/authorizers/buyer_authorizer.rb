class BuyerAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    # Buyers are ONLY created through user registration
    false
  end
end
