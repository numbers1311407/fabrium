class CreateUserMills < ActiveRecord::Migration
  def change
    create_table :user_mills, force: true do |t|
      t.belongs_to :mill
      t.belongs_to :user
    end
  end
end
