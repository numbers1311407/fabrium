class CreateMills < ActiveRecord::Migration
  def change
    create_table :mills do |t|
      t.references :creator
      t.string :name, index: true, unique: true
      t.boolean :active, default: false
      t.timestamps
    end
  end
end
