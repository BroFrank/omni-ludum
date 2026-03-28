class UpdateRefreshTokensForeignKey < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :refresh_tokens, :users
    add_foreign_key :refresh_tokens, :users, on_delete: :cascade
  end
end
