class CreatePlatforms < ActiveRecord::Migration[7.2]
  def change
    create_table :platforms do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.boolean :is_disabled, null: false, default: false

      t.index :slug, unique: true
      t.index :name
      t.index :is_disabled

      t.timestamps
    end
  end
end
