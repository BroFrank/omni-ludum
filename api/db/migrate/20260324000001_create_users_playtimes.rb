class CreateUsersPlaytimes < ActiveRecord::Migration[7.2]
  def change
    create_table :users_playtimes do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :game, null: false, foreign_key: { on_delete: :cascade }
      t.integer :minutes_regular
      t.integer :minutes_100
      t.boolean :is_disabled, null: false, default: false

      t.timestamps
    end

    add_check_constraint :users_playtimes, 'minutes_regular >= 0', name: 'check_minutes_regular_positive'
    add_check_constraint :users_playtimes, 'minutes_100 >= 0', name: 'check_minutes_100_positive'

    add_index :users_playtimes, [ :user_id, :created_at ]
    add_index :users_playtimes, [ :game_id, :created_at ]

    add_index :users_playtimes, [ :user_id, :game_id ], unique: true, where: 'is_disabled = false', name: 'index_users_playtimes_on_user_id_and_game_id_unique'
  end
end
