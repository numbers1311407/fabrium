class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.integer :kind, default: 0
      t.string :name
      t.timestamps
    end

    add_index :properties, :name
    add_index :properties, :kind
  end
end
