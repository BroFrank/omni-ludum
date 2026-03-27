class CreatePublishers < ActiveRecord::Migration[7.2]
  def change
    create_table :publishers do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :publishers, :name, unique: true
    add_index :publishers, :slug, unique: true
    add_index :publishers, :type
  end
end
