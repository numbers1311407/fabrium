class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.references :fabric_variant, index: true 
      t.references :cart, index: true
      t.references :mill, index: true # denormalized
      t.string :fabrium_id # denormalized
      t.integer :state, default: 0
      t.text :notes
      t.decimal :sample_yardage
      t.string :tracking_number
      t.timestamps
    end
  end
end
