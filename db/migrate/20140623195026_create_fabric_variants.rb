class CreateFabricVariants < ActiveRecord::Migration
  def change
    create_table :fabric_variants do |t|
      t.references :fabric
      t.integer :fabrium_id
      t.integer :mill_id
      t.decimal :lab, array: true, default: [0,0,0]
      t.timestamps
    end

    add_index :fabric_variants, :lab, using: 'gin'
  end
end
