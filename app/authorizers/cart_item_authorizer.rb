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
    # admins can remove items always though they shouldn't need to and
    # (and as of yet don't have a cart view)
    retv = user.is_admin? ||

    # User is buyer and built the cart
    (user.is_buyer? && cart.buyer == user.meta && cart.buyer_build? && cart.buyer_created?) ||

    # User is mill and built the cart
    (user.is_mill? && cart.mill == user.meta && cart.mill_build? && cart.mill_created?)

    retv
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
