class CreateFabrics < ActiveRecord::Migration
  def change
    create_table :fabrics do |t|
      t.integer :fabrium_id
      t.numrange :price_eu
      t.numrange :price_us
      t.timestamps
    end

    add_index :fabrics, :fabrium_id, unique: true

    reversible do |dir|
      dir.up   { execute "CREATE SEQUENCE #{Fabric::FABRIUM_ID_SEQ} START #{Fabric::FABRIUM_ID_START}" }
      dir.down { execute "DROP SEQUENCE #{Fabric::FABRIUM_ID_SEQ}" }
    end
  end
end
