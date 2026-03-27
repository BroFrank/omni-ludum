class AddPublisherIdToGames < ActiveRecord::Migration[7.2]
  def change
    add_reference :games, :publisher, null: true, foreign_key: { on_delete: :nullify }
  end
end
