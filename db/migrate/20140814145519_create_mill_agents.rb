class CreateMillAgents < ActiveRecord::Migration
  def change
    create_table :mill_agents do |t|
      t.references :mill
      t.string :contact, :email, :phone, :country, default: ""
      t.timestamps
    end
  end
end
