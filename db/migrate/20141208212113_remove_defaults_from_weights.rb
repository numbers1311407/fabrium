class RemoveDefaultsFromWeights < ActiveRecord::Migration
  def up
    change_column :fabrics, :gsm, :decimal, precision: 8, scale: 2, default: nil
    change_column :fabrics, :glm, :decimal, precision: 8, scale: 2, default: nil
    change_column :fabrics, :osy, :decimal, precision: 8, scale: 2, default: nil
  end

  def down
    change_column :fabrics, :gsm, :decimal, precision: 8, scale: 2, default: 0
    change_column :fabrics, :glm, :decimal, precision: 8, scale: 2, default: 0
    change_column :fabrics, :osy, :decimal, precision: 8, scale: 2, default: 0
  end
end
