class AuditLogJob < ApplicationJob
  queue_as :default

  def perform(user_id:, table_name:, record_id:, action:, old_values: nil, new_values: nil)
    AuditLogService.log_action(
      user_id: user_id,
      table_name: table_name,
      record_id: record_id,
      action: action,
      old_values: old_values,
      new_values: new_values
    )
  rescue => e
    Rails.logger.error "AuditLogJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end
