class CreateMills < ActiveRecord::Migration
  def change
    create_table :mills do |t|
      t.string :name, index: true, unique: true
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
