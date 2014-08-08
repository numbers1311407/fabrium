class ChangeCartItemsRequestYardageDefaultFalse < ActiveRecord::Migration
  def change
    change_column :cart_items, :request_yardage, :boolean, default: false
  end
end
