class AdminAuthorizer < ApplicationAuthorizer
  def self.default(adjective, user)
    user.is_admin?
  end
end
