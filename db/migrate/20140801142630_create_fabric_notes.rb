class CreateFabricNotes < ActiveRecord::Migration
  def change
    create_table :fabric_notes do |t|
      t.references :user
      t.references :fabric
      t.text :note
      t.timestamps
    end
  end
end
