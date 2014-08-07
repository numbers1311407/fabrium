class MillAuthorizer < FabriumResourceAuthorizer
  def creatable_by?(user)
    # Mills are ONLY created through user registration
    false
  end
end
