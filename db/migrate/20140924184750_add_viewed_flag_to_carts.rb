class AddViewedFlagToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :public_viewed, :datetime
  end
end
