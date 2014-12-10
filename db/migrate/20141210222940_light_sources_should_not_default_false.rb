class LightSourcesShouldNotDefaultFalse < ActiveRecord::Migration
  def up
    change_column :mills, :light_sources, :string, default: nil
  end

  def down
    change_column :mills, :light_sources, :string, default: 'false'
  end
end
