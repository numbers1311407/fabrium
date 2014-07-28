class CreateFabricVariants < ActiveRecord::Migration
  def change
    create_table :fabric_variants do |t|
      t.references :fabric
      t.integer :position, default: 0
      t.string :fabrium_id
      t.string :item_number, default: ""
      t.integer :mill_id
      t.string :color
      t.decimal :cie_l, :cie_a, :cie_b, default: 0
      t.string :image_uid
      t.string :image_name
      t.string :image_crop
      t.string :image_width
      t.string :image_height
      t.boolean :in_stock, default: false
      t.timestamps
    end

    add_index :fabric_variants, [:cie_l, :cie_a, :cie_b], name: 'by_cie_lab'
  end
end
