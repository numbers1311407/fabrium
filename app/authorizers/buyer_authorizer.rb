class BuyerAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    # Buyers are only created through the reg process
    false
  end

  def readable_by?(user)
    admin_or_buyer_user?(user)
  end

  def updatable_by?(user)
    admin_or_buyer_user?(user)
  end

  def deletable_by?(user)
    user.is_admin? && resource.carts.state(:closed).none?
  end

  def administerable_by?(user)
    user.is_admin?
  end

  protected

  def admin_or_buyer_user?(user)
    user.is_admin? || user.is_buyer? && user.meta == resource
  end

end
