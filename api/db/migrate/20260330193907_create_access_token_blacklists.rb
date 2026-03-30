class CreateAccessTokenBlacklists < ActiveRecord::Migration[7.2]
  def change
    create_table :access_token_blacklists do |t|
      t.string :jti, null: false
      t.datetime :expires_at, null: false
      t.string :reason
      t.bigint :user_id

      t.timestamps
    end
    add_index :access_token_blacklists, :jti, unique: true
    add_index :access_token_blacklists, :expires_at
    add_index :access_token_blacklists, :user_id
  end
end
