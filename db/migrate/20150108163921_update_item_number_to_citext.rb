class UpdateItemNumberToCitext < ActiveRecord::Migration
  def up
    change_column :fabrics, :item_number, :citext
    change_column :fabric_variants, :item_number, :citext
  end

  def down
    change_column :fabrics, :item_number, :string
    change_column :fabric_variants, :item_number, :string
  end
end
