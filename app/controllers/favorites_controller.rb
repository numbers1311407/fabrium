class FavoritesController < ResourceController

  respond_to :html, only: [:update]

  protected

  def begin_of_association_chain
    current_user
  end
end
