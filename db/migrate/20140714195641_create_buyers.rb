class CreateBuyers < ActiveRecord::Migration
  def change
    create_table :buyers do |t|
      t.references :pending_cart
      t.timestamps
    end
  end
end
