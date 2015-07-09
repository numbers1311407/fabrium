class CreateUserMills < ActiveRecord::Migration
  def change
    create_table :user_mills, force: true do |t|
      t.belongs_to :mill
      t.belongs_to :user
    end

    reversible do |dir|
      dir.up do
        User.mills.each do |user|
          user.mills = [user.meta]
        end
      end
    end
  end
end
