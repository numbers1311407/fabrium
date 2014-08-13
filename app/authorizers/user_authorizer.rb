class UserAuthorizer < ApplicationAuthorizer

  def creatable_by?(user)
    # only admin mills can create users (for their own mill)
    user.is_admin? || user.admin? && user.is_mill? && resource.meta == user.meta
  end

  # remember this is only to view the admin users, index not to actually
  # touch any records (which is why we don't care what type of user the
  # resource is, as the scope will be handled at the resource control)
  def administerable_by?(user)
    user.is_admin? || (user.admin? && user.is_mill?)
  end

  def readable_by?(user)
    _permitted?(user)
  end

  def activatable_by? user
    user.is_admin?
  end

  def updatable_by? user
    _permitted?(user)
  end

  def deletable_by? user
    (user != resource) && (
      user.is_admin? ||
      (user.admin? && user.is_mill? && resource.meta == user.meta)
    )
  end

  protected

  def _permitted?(user)
    user.is_admin? ||
    (resource.is_buyer? && user.meta == resource.meta) ||
    (resource.is_mill? && user.meta == resource.meta)
  end
end
