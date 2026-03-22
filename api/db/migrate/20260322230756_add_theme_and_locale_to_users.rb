class AddThemeAndLocaleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :theme, :string, default: 'light', null: false
    add_column :users, :locale, :string, default: 'en', null: false
  end
end
