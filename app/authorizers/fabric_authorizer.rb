class FabricAuthorizer < ApplicationAuthorizer
  def administerable_by?(user)
    user.is_admin? || user.is_mill?
  end

  def creatable_by?(user)
    user.is_admin? || is_mill?(user)
  end

  # fabrics are readable by all, unless they're archived
  def readable_by?(user)
    !resource.archived? || (user.is_admin? || is_mill?(user))
  end

  def updatable_by?(user)
    user.is_admin? || is_mill?(user)
  end

  # fabrics become undeletable once they have orders
  def deletable_by?(user)
    resource.orders_count.zero? && (user.is_admin? || is_mill?(user))
  end

  protected

  def is_mill?(user)
    user.is_mill? && resource.mill_id == user.meta.id
  end
end
