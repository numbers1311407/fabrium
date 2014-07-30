class CreateBuyerMills < ActiveRecord::Migration
  def change
    create_table :buyer_mills do |t|
      t.references :mill, index: true
      t.references :buyer, index: true
      t.integer :relationship, default: 0

      t.timestamps
    end
  end
end
