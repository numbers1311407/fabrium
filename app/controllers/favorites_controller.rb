class FavoritesController < ResourceController
  defaults finder: :find_by_fabric_variant_id!

  permit_params :fabric_variant_id

  respond_to :html, only: [:update]

  protected

  def begin_of_association_chain
    current_user
  end
end
