class CreateMillContacts < ActiveRecord::Migration
  def change
    create_table :mill_contacts do |t|
      t.references :mill
      t.string :kind, :name, :email, :phone, default: ""
      t.timestamps
    end
  end
end
