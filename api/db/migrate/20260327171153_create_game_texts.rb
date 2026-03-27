class CreateGameTexts < ActiveRecord::Migration[7.2]
  def change
    create_table :game_texts do |t|
      t.bigint :game_id, null: false
      t.string :lang_code, null: false, limit: 2
      t.text :description
      t.text :trivia

      t.timestamps
    end

    add_foreign_key :game_texts, :games, on_delete: :cascade
    add_index :game_texts, :game_id
    add_index :game_texts, %i[game_id lang_code], unique: true
  end
end
