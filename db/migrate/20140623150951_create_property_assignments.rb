class CreatePropertyAssignments < ActiveRecord::Migration
  def change
    create_table :material_assignments do |t|
      t.references :material, index: true
      t.references :fabric, index: true
      t.string :value
    end
  end
end
