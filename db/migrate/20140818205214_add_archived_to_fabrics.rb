class AddArchivedToFabrics < ActiveRecord::Migration
  def change
    add_column :fabrics, :archived, :boolean, default: false
  end
end
