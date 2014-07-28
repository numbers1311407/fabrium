class CreatePropertyAssignments < ActiveRecord::Migration
  def change
    create_table :material_assignments do |t|
      t.references :material
      t.references :fabric
      t.string :value
    end

    add_index :material_assignments, :material_id
    add_index :material_assignments, :fabric_id
  end
end
