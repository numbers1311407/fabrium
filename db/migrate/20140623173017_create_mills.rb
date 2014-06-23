class CreateMills < ActiveRecord::Migration
  def change
    create_table :mills do |t|
      t.string :name
      t.timestamps
    end
  end
end
