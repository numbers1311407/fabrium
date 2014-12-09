class ChangeLightSourcesToString < ActiveRecord::Migration
  def up
    change_column :mills, :light_sources, :string
  end

  def down
    change_column :mills, :light_sources, :integer
  end
end
