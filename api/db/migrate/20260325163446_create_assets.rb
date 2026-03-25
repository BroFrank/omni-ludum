class CreateAssets < ActiveRecord::Migration[7.2]
  def change
    create_table :assets do |t|
      t.bigint :game_id, null: false
      t.string :asset_type, null: false
      t.string :storage_path, null: false
      t.string :mime_type, null: false
      t.integer :file_size, null: false
      t.integer :order_index
      t.boolean :is_disabled, default: false, null: false

      t.timestamps

      t.index :game_id
      t.index :asset_type
      t.index :is_disabled
      t.index [:game_id, :asset_type]
      t.index [:game_id, :order_index]
    end

    add_foreign_key :assets, :games, on_delete: :cascade

    add_check_constraint :assets,
      "asset_type IN ('COVER', 'SCREENSHOT', 'MANUAL')",
      name: "check_asset_type_valid"

    add_check_constraint :assets,
      "file_size > 0",
      name: "check_file_size_positive"

    add_check_constraint :assets,
      "order_index IS NULL OR order_index >= 0",
      name: "check_order_index_non_negative"
  end
end
