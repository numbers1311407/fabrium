class CreatePropertyAssignments < ActiveRecord::Migration
  def change
    create_table :tag_assignments do |t|
      t.references :tag
      t.references :fabric
    end

    create_table :fiber_assignments do |t|
      t.references :fiber
      t.references :fabric
      t.string :value
    end

    add_index :tag_assignments, :tag_id
    add_index :tag_assignments, :fabric_id

    add_index :fiber_assignments, :fiber_id
    add_index :fiber_assignments, :fabric_id
  end
end
