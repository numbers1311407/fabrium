class BuyerAuthorizer < FabriumResourceAuthorizer
  def creatable_by?(user)
    # Buyers are ONLY created through user registration
    false
  end
end
