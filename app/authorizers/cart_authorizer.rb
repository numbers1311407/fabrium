class CartAuthorizer < ApplicationAuthorizer

  def administerable_by?(user)
    true
  end

  def creatable_by?(user)
    user.is_admin? || is_mill?(user) || is_buyer?(user)
  end

  def readable_by?(user)
    operable_by?(user)
  end

  def updatable_by?(user)
    operable_by?(user)
  end

  def deletable_by?(user)
    # Carts are only deletable via the admin in the `mill_build` (first) 
    # state.
    resource.mill_build? && (user.is_admin? || is_mill?(user))
  end

  protected

  def is_mill?(user)
    user.is_mill? && resource.mill_id == user.meta.id 
  end

  def is_buyer?(user)
    user.is_buyer? && resource.buyer_id == user.meta.id 
  end

  def operable_by?(user)
    # admins can do whatever here
    user.is_admin? ||

    # mills can operate on their own resources in the initial `mill_build`
    # state or any state after `pending`
    is_mill?(user) && resource.state.not?(:buyer_build, :pending) ||

    # buyers can operate on their own resources not in the mill build state 
    # and that ARE NOT subcarts (they will see the parent cart)
    is_buyer?(user) && !resource.mill_build? && !resource.subcart?
  end
end
