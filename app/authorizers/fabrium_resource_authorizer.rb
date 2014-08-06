class FabriumResourceAuthorizer < ApplicationAuthorizer
  def creatable_by? user
    user.is_admin?
  end

  # Open read permissions as much of these resources are used by all
  # roles.  Extend the class to override.
  def readable_by? user
    true
  end

  def updatable_by? user
    user.is_admin?
  end

  def deletable_by? user
    user.is_admin?
  end

  def administerable_by? user
    user.is_admin?
  end

end
