class AddMaterialsHstoreToFabrics < ActiveRecord::Migration
  def change
    add_column :fabrics, :materials, :hstore
  end
end
