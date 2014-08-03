class CreateApprovedDomains < ActiveRecord::Migration
  def change
    create_table :approved_domains do |t|
      t.string :name
      t.integer :entity, default: 0
      t.timestamps
    end
  end
end
