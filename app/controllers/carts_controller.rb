class CartsController < ResourceController
  defaults finder: :find_by_public_id!
  custom_actions resource: [:pending_cart]
  authority_actions pending_cart: :read

  skip_before_filter :authenticate_user!, :only => [:show]

  permit_params [
    cart_items: [
      :id, 
      :notes, 
      :sample_yardage, 
      :tracking_number, 
      :fabric_variant_id,
      :_destroy
    ]
  ]

  def pending_cart
    @cart = get_pending_cart

    raise ActiveRecord::RecordNotFound unless @cart

    respond_with(@cart) do |wants|
      wants.html { render 'show' }
    end
  end

  protected

  def current_user
    user = super
    user ||= User.new if 'show' == params[:action]
    user
  end

  def get_pending_cart
    current_user.meta.pending_cart unless current_user.is_admin?
  end

end
