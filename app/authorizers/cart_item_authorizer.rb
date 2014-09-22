# Other authorizers should subclass this one
class CartItemAuthorizer < ApplicationAuthorizer

  def creatable_by?(user)
    operable_by?(user)
  end

  def readable_by?(user)
    operable_by?(user)
  end

  def updatable_by?(user)
    operable_by?(user)
  end

  def deletable_by?(user)
    # NOTE admins can't delete cart items.  Is this right?
    # User is buyer and built the cart
    (user.is_buyer? && cart.buyer == user.meta && cart.buyer_build? && cart.buyer_created?) ||

    # User is mill and built the cart
    (user.is_mill? && cart.mill == user.meta && cart.mill_build? && cart.mill_created?)
  end

  protected

  def operable_by?(user)
    user.is_admin? ||
    (user.is_buyer? && cart.buyer == user.meta) ||
    (user.is_mill? && cart.mill == user.meta)
  end

  def cart
    resource.cart
  end
end
