class ChangeCurrentSampleYardageAvailabilityToText < ActiveRecord::Migration
  def up
    change_column :cart_items, :sample_yardage, :text
  end

  def down
    change_column :cart_items, :sample_yardage, :decimal
  end
end
