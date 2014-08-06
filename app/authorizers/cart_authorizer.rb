class CartAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    user.is_admin? ||
    resource.buyer.blank? || 
    user_is_buyer_and_owns_cart?(user) ||
    user_is_mill_and_owns_cart?(user) ||
    user_is_mill_and_responsible_for_item_in_cart?(user)
  end

  protected

  def user_is_buyer_and_owns_cart?(user)
    user.is_buyer? && resource.buyer_id == user.meta.id
  end

  def user_is_mill_and_owns_cart?(user)
    user.is_mill? && resource.mill_id == user.meta.id
  end

  def user_is_mill_and_responsible_for_item_in_cart?(user)
    user.is_mill? && resource.cart_items.exists?(mill_id: user.meta.id)
  end
end
