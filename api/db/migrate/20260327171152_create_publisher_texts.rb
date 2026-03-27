class CreatePublisherTexts < ActiveRecord::Migration[7.2]
  def change
    create_table :publisher_texts do |t|
      t.bigint :publisher_id, null: false
      t.string :lang_code, null: false, limit: 2
      t.text :description

      t.timestamps
    end

    add_foreign_key :publisher_texts, :publishers, on_delete: :cascade
    add_index :publisher_texts, :publisher_id
    add_index :publisher_texts, %i[publisher_id lang_code], unique: true
  end
end
