class AddDomainListToMills < ActiveRecord::Migration
  def change
    add_column :mills, :domains, :text, array: true, default: []
    add_column :mills, :domain_filter, :integer, default: 0

    add_index :mills, :domains, using: 'gin'
  end
end
