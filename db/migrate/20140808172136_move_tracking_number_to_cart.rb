class MoveTrackingNumberToCart < ActiveRecord::Migration
  def change
    add_column :carts, :tracking_number, :string
    remove_column :cart_items, :tracking_number
  end
end
