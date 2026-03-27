class AddIsDisabledToPublishers < ActiveRecord::Migration[7.2]
  def change
    add_column :publishers, :is_disabled, :boolean, default: false, null: false
    add_index :publishers, :is_disabled
  end
end
