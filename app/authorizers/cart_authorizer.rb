class CartAuthorizer < ApplicationAuthorizer

  def administerable_by?(user)
    # everyone can see carts
    true
  end

  def readable_by?(user)
    # all users can read the index
    resource.new_record? ||

    # admins can view all
    user.is_admin? ||

    # mills see their own resources not in the buyer build state
    user.is_mill? && mill_readable?(user) ||

    # buyers see their own resources not in the mill build state
    user.is_buyer? && buyer_readable?(user)
  end

  protected

  def mill_readable?(user)
    resource.mill_id == user.meta.id && !resource.buyer_build?
  end

  def buyer_readable?(user)
    resource.buyer_id == user.meta.id && !resource.mill_build?
  end
end
