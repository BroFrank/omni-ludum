class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: USER_ROLES::REGULAR
      t.boolean :is_disabled, null: false, default: false
      t.string :slug

      t.index :username, unique: true
      t.index :email, unique: true
      t.index :slug, unique: true
      t.index :is_disabled

      t.timestamps
    end
  end
end
