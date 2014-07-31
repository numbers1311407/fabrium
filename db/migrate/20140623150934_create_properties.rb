class CreateProperties < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, index: true
      t.timestamps
    end

    create_table :categories do |t|
      t.string :name, index: true
      t.timestamps
    end

    create_table :materials do |t|
      t.string :name, index: true
      t.timestamps
    end

    create_table :dye_methods do |t|
      t.string :name, index: true
      t.timestamps
    end
  end
end
