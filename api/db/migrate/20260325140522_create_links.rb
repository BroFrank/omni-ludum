class CreateLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :links do |t|
      t.bigint :game_id, null: false
      t.string :link_type, null: false
      t.text :url, null: false
      t.string :title, null: false
      t.boolean :is_disabled, null: false, default: false

      t.index :game_id
      t.index :link_type
      t.index [ :game_id, :link_type ]

      t.timestamps
    end

    add_foreign_key :links, :games, column: :game_id, on_delete: :cascade

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE links
            ADD CONSTRAINT check_link_type_valid CHECK (link_type IN ('TRAILER', 'LONGPLAY', 'SPEEDRUN', 'OTHER'));
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE links
            DROP CONSTRAINT check_link_type_valid;
        SQL
      end
    end
  end
end
