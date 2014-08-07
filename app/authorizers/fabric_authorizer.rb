class FabricAuthorizer < ApplicationAuthorizer
  def administerable_by?(user)
    user.is_admin? || user.is_mill?
  end

  protected

  def user_is_mill_and_owns_resource?(user)
    user.is_mill? && resource.mill_id == user.meta.id
  end
end
