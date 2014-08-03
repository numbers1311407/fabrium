class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.references :mill, index: true
      t.references :buyer, index: true
      t.string :public_id, index: true
      t.integer :state, default: 0
      t.timestamps
    end
  end
end
