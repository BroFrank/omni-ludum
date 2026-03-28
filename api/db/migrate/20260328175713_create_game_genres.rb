class CreateGameGenres < ActiveRecord::Migration[7.2]
  def change
    create_table :game_genres do |t|
      t.bigint :game_id, null: false
      t.bigint :genre_id, null: false
      t.boolean :is_disabled, null: false, default: false

      t.timestamps
    end

    add_foreign_key :game_genres, :games, on_delete: :cascade
    add_foreign_key :game_genres, :genres, on_delete: :cascade
    add_index :game_genres, :game_id
    add_index :game_genres, :genre_id
    add_index :game_genres, %i[game_id genre_id], unique: true
  end
end
