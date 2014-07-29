class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :user, :fabric_variant
      t.timestamps
    end
  end
end
