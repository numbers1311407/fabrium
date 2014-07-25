class CreateProperties < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.timestamps
    end

    create_table :categories do |t|
      t.string :name
      t.timestamps
    end

    create_table :fibers do |t|
      t.string :name
      t.timestamps
    end

    create_table :dye_methods do |t|
      t.string :name
      t.timestamps
    end

    add_index :tags, :name
    add_index :categories, :name
    add_index :fibers, :name
    add_index :dye_methods, :name
  end
end
