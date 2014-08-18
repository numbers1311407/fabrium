class FabricAuthorizer < ApplicationAuthorizer
  def administerable_by?(user)
    user.is_admin? || user.is_mill?
  end

  def updatable_by?(user)
    user.is_admin? || is_mill?(user)
  end

  # fabrics become undeletable once they have orders
  def deletable_by?(user)
    resource.orders_count.zero? && 
        (user.is_admin? || is_mill?(user))
  end

  protected

  def is_mill?(user)
    user.is_mill? && resource.mill_id == user.meta.id
  end
end
