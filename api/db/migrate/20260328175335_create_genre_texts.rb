class CreateGenreTexts < ActiveRecord::Migration[7.2]
  def change
    create_table :genre_texts do |t|
      t.bigint :genre_id, null: false
      t.string :lang_code, null: false, limit: 2
      t.text :description

      t.timestamps
    end

    add_foreign_key :genre_texts, :genres, on_delete: :cascade
    add_index :genre_texts, :genre_id
    add_index :genre_texts, %i[genre_id lang_code], unique: true
  end
end
