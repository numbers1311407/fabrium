class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.references :mill, index: true
      t.references :buyer, index: true
      t.references :creator, polymorphic: true
      t.references :parent
      t.string :buyer_email
      t.string :name
      t.string :public_id
      t.string :fabrium_id
      t.integer :state, default: 0
      t.timestamps
    end
  end
end
