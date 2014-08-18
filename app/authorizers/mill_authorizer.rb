class MillAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    user.is_admin?
  end

  def readable_by?(user)
    admin_or_mill_user?(user)
  end

  def updatable_by?(user)
    admin_or_mill_user?(user)
  end

  def deletable_by?(user)
    user.is_admin?
  end

  def administerable_by?(user)
    user.is_admin?
  end

  protected

  def admin_or_mill_user?(user)
    user.is_admin? || user.is_mill? && user.meta == resource
  end

  def admin_or_mill_admin?(user)
    user.is_admin? || user.is_mill? && user.admin? && user.meta == resource
  end

end
