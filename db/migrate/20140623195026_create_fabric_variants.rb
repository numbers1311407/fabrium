class CreateFabricVariants < ActiveRecord::Migration
  def change
    create_table :fabric_variants do |t|
      t.references :fabric
      t.integer :fabrium_id
      t.integer :mill_id
      t.string :color
      t.decimal :cie_l, :cie_a, :cie_b, default: 0
      t.timestamps
    end

    add_index :fabric_variants, [:cie_l, :cie_a, :cie_b], name: 'by_cie_lab'
  end
end
