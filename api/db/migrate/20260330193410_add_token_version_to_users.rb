class AddTokenVersionToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :token_version, :integer, null: false, default: 0
    add_index :users, :token_version
  end
end
