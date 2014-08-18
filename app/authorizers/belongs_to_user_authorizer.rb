class BelongsToUserAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    belongs_to?(user)
  end

  def readable_by?(user)
    belongs_to?(user)
  end

  def updatable_by?(user)
    belongs_to?(user)
  end

  def deletable_by?(user)
    belongs_to?(user)
  end

  protected

  def belongs_to?(user)
    user.id == resource.user_id
  end
end
