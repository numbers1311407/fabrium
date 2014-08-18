class FabricVariantAuthorizer < FabricAuthorizer
  # inherits directly from fabric authorizer
  def readable_by?(user)
    resource.fabric.blank? || resource.fabric.readable_by?(user)
  end

  # never deleted in the admin (only deleted through fabric dependency
  # hook)
  def deletable_by?(user)
    false
  end
end
