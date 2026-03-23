class CreateGameRatingRecalculations < ActiveRecord::Migration[7.2]
  def change
    create_table :game_rating_recalculations do |t|
      t.references :game, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :scheduled_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :processed_at
      t.string :status, null: false, default: 'pending'
      t.text :error_message

      t.timestamps
    end

    add_index :game_rating_recalculations, [:game_id, :status], unique: true, where: "status = 'pending'", name: 'index_game_rating_recalculations_unique_pending'
    
    add_index :game_rating_recalculations, :scheduled_at
    add_index :game_rating_recalculations, :status
  end
end
