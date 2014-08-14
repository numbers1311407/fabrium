class CreateMillReferences < ActiveRecord::Migration
  def change
    create_table :mill_references do |t|
      t.references :mill
      t.string :name, :email, :phone, :company, default: ""
      t.timestamps
    end
  end
end
