class AuditLogService
  def self.log_action(user_id:, table_name:, record_id:, action:, old_values: nil, new_values: nil)
    AuditLog.create!(
      user_id: user_id,
      table_name: table_name,
      record_id: record_id,
      action: action,
      old_values: old_values || {},
      new_values: new_values || {}
    )
  end

  def self.log_create(user_id:, table_name:, record_id:, new_values:)
    log_action(
      user_id: user_id,
      table_name: table_name,
      record_id: record_id,
      action: AUDIT_ACTIONS::CREATE,
      new_values: new_values
    )
  end

  def self.log_update(user_id:, table_name:, record_id:, old_values:, new_values:)
    log_action(
      user_id: user_id,
      table_name: table_name,
      record_id: record_id,
      action: AUDIT_ACTIONS::UPDATE,
      old_values: old_values,
      new_values: new_values
    )
  end

  def self.log_delete(user_id:, table_name:, record_id:, old_values:)
    log_action(
      user_id: user_id,
      table_name: table_name,
      record_id: record_id,
      action: AUDIT_ACTIONS::DELETE,
      old_values: old_values
    )
  end

  def self.get_human_readable_table_name(table_name, locale = I18n.locale)
    I18n.t("audit.tables.#{table_name}", default: table_name.to_s.humanize, locale: locale)
  end

  def self.get_human_readable_field_name(table_name, field_name, locale = I18n.locale)
    I18n.t("audit.fields.#{table_name}.#{field_name}", default: field_name.to_s.humanize, locale: locale)
  end

  def self.format_for_api(audit_log, locale = I18n.locale)
    {
      id: audit_log.id,
      user_id: audit_log.user_id,
      table_name: get_human_readable_table_name(audit_log.table_name, locale),
      table_name_raw: audit_log.table_name,
      record_id: audit_log.record_id,
      action: audit_log.action,
      action_label: I18n.t("audit.actions.#{audit_log.action.downcase}", default: audit_log.action, locale: locale),
      old_values: format_values(audit_log.old_values, audit_log.table_name, locale),
      new_values: format_values(audit_log.new_values, audit_log.table_name, locale),
      created_at: audit_log.created_at.iso8601
    }
  end

  def self.format_values(values, table_name, locale = I18n.locale)
    return {} if values.blank?

    values.transform_keys do |key|
      get_human_readable_field_name(table_name, key, locale)
    end
  end
end
