class ChangePrintingMethodsToString < ActiveRecord::Migration
  def up
    change_column :mills, :printing_methods, :string
  end

  def down
    change_column :mills, :printing_methods, :integer
  end
end
