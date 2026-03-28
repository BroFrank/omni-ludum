module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :audit_create_callback
    after_update :audit_update_callback
    before_destroy :audit_destroy_callback, if: respond_to?(:is_disabled)
  end

  private

  def audit_create_callback
    user_id = get_current_user_id
    new_values = attributes.except("id", "created_at", "updated_at")

    AuditLogJob.perform_later(
      user_id: user_id,
      table_name: self.class.table_name,
      record_id: id,
      action: AUDIT_ACTIONS::CREATE,
      new_values: new_values
    )
  end

  def audit_update_callback
    user_id = get_current_user_id
    return unless saved_changes?

    old_values = {}
    new_values = {}

    saved_changes.each do |field, values|
      next if %w[updated_at].include?(field)

      old_values[field] = values[0]
      new_values[field] = values[1]
    end

    return if old_values.empty?

    AuditLogJob.perform_later(
      user_id: user_id,
      table_name: self.class.table_name,
      record_id: id,
      action: AUDIT_ACTIONS::UPDATE,
      old_values: old_values,
      new_values: new_values
    )
  end

  def audit_destroy_callback
    user_id = get_current_user_id
    old_values = attributes.except("id", "created_at", "updated_at")

    AuditLogJob.perform_later(
      user_id: user_id,
      table_name: self.class.table_name,
      record_id: id,
      action: AUDIT_ACTIONS::DELETE,
      old_values: old_values
    )
  end

  def get_current_user_id
    Thread.current[:current_user_id]
  end
end
