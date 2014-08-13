# Other authorizers should subclass this one
class CartItemAuthorizer < ApplicationAuthorizer

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

  def cart
    resource.cart
  end
end
