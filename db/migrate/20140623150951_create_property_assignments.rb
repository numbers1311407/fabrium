class CreatePropertyAssignments < ActiveRecord::Migration
  def change
    create_table :property_assignments do |t|
      t.references :property
      t.references :fabric
      t.string :value
      t.timestamps
    end

    add_index :property_assignments, :property_id
    add_index :property_assignments, :fabric_id
  end
end
