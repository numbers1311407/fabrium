class CartItemsController < ResourceController
  defaults finder: :find_by_fabric_variant_id!, instance_name: :item, route_instance_name: :item

  permit_params :fabric_variant_id

  protected

  def begin_of_association_chain
    if current_user.is_buyer?
      current_user.meta.pending_cart
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
