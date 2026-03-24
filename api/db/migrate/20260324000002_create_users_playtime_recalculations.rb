class CreateUsersPlaytimeRecalculations < ActiveRecord::Migration[7.2]
  def change
    create_table :users_playtime_recalculations do |t|
      t.references :game, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :scheduled_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :processed_at
      t.string :status, null: false, default: 'pending'
      t.text :error_message

      t.timestamps
    end

    add_index :users_playtime_recalculations, [ :game_id, :status ], unique: true, where: "status = 'pending'", name: 'index_users_playtime_recalculations_unique_pending'

    add_index :users_playtime_recalculations, :scheduled_at
    add_index :users_playtime_recalculations, :status
  end
end
