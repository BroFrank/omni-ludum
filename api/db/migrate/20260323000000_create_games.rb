class CreateGames < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.string :name, null: false
      t.integer :release_year
      t.float :rating_avg
      t.float :difficulty_avg
      t.integer :playtime_avg
      t.integer :playtime_100_avg
      t.boolean :is_dlc, null: false, default: false
      t.boolean :is_mod, null: false, default: false
      t.boolean :is_disabled, null: false, default: false
      t.bigint :base_game_id

      t.index :name
      t.index :release_year
      t.index :is_disabled
      t.index :base_game_id

      t.timestamps
    end

    add_foreign_key :games, :games, column: :base_game_id
  end
end
