class MillAuthorizer < FabriumResourceAuthorizer
  def creatable_by?(user)
    # Mills are ONLY created through user registration
    user.is_admin?
  end
end
