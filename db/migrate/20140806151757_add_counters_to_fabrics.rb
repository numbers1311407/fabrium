class AddCountersToFabrics < ActiveRecord::Migration
  def change
    add_column :fabrics, :favorites_count, :integer, default: 0
    add_column :fabrics, :orders_count, :integer, default: 0
    add_column :fabrics, :views_count, :integer, default: 0
  end
end
