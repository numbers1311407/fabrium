class MakeMaterialAssignmentsValueNumeric < ActiveRecord::Migration
  def up
    change_column :material_assignments, :value, 'decimal USING CAST(value AS decimal)'
  end

  def down
    change_column :material_assignments, :value, 'varchar USING CAST(value AS varchar)'
  end
end
