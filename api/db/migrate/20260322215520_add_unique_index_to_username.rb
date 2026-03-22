class AddUniqueIndexToUsername < ActiveRecord::Migration[7.2]
  def change
    add_index :users, "LOWER(username)", unique: true, name: "index_users_on_username_ci"
  end
end
