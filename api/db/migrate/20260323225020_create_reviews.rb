class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :game, null: false, foreign_key: { on_delete: :cascade }
      t.integer :rating, null: false
      t.integer :difficulty, null: false
      t.text :comment
      t.boolean :is_disabled, default: false, null: false

      t.timestamps
    end

    # Ограничения CHECK для rating и difficulty
    execute <<-SQL
      ALTER TABLE reviews
        ADD CONSTRAINT check_rating_range CHECK (rating >= 0 AND rating <= 10),
        ADD CONSTRAINT check_difficulty_range CHECK (difficulty >= 0 AND difficulty <= 10);
    SQL

    add_index :reviews, [:game_id, :created_at]
    add_index :reviews, [:user_id, :created_at]
    
    add_index :reviews, [:user_id, :game_id], unique: true, where: 'is_disabled = false', name: 'index_reviews_on_user_id_and_game_id_unique'
  end
end
