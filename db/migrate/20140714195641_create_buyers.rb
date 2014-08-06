class CreateBuyers < ActiveRecord::Migration
  def change
    create_table :buyers do |t|
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :position
      t.string :shipping_address_1
      t.string :shipping_address_2
      t.string :city
      t.string :subregion
      t.string :country
      t.string :phone
      t.string :postal_code
      t.timestamps
    end
  end
end
