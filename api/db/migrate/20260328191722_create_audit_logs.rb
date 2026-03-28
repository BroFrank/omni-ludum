class CreateAuditLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_logs do |t|
      t.bigint :user_id, null: true
      t.string :table_name, null: false
      t.bigint :record_id, null: false
      t.string :action, null: false
      t.jsonb :old_values, default: {}, null: true
      t.jsonb :new_values, default: {}, null: true

      t.index :user_id
      t.index :table_name
      t.index :action
      t.index :created_at
      t.index %i[table_name record_id], name: 'index_audit_logs_on_table_and_record'

      t.timestamps
    end

    add_foreign_key :audit_logs, :users, column: :user_id, on_delete: :nullify

    add_check_constraint :audit_logs, "action IN ('CREATE', 'UPDATE', 'DELETE')", name: 'check_audit_logs_action'
  end
end
