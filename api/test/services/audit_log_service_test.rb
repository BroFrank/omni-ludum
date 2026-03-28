require "test_helper"

class AuditLogServiceTest < ActiveSupport::TestCase
  test "log_action creates audit log" do
    audit_log = AuditLogService.log_action(
      user_id: nil,
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE,
      old_values: {},
      new_values: { "name" => "Test" }
    )

    assert audit_log.persisted?
    assert_nil audit_log.user_id
    assert_equal "games", audit_log.table_name
    assert_equal 1, audit_log.record_id
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_equal({ "name" => "Test" }, audit_log.new_values)
  end

  test "log_create creates audit log with CREATE action" do
    audit_log = AuditLogService.log_create(
      user_id: nil,
      table_name: "games",
      record_id: 1,
      new_values: { "name" => "Test" }
    )

    assert audit_log.persisted?
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_equal({}, audit_log.old_values)
  end

  test "log_update creates audit log with UPDATE action" do
    audit_log = AuditLogService.log_update(
      user_id: nil,
      table_name: "games",
      record_id: 1,
      old_values: { "name" => "Old" },
      new_values: { "name" => "New" }
    )

    assert audit_log.persisted?
    assert_equal AUDIT_ACTIONS::UPDATE, audit_log.action
    assert_equal({ "name" => "Old" }, audit_log.old_values)
    assert_equal({ "name" => "New" }, audit_log.new_values)
  end

  test "log_delete creates audit log with DELETE action" do
    audit_log = AuditLogService.log_delete(
      user_id: nil,
      table_name: "games",
      record_id: 1,
      old_values: { "name" => "Test" }
    )

    assert audit_log.persisted?
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_equal({ "name" => "Test" }, audit_log.old_values)
    assert_equal({}, audit_log.new_values)
  end

  test "get_human_readable_table_name returns translated name" do
    assert_equal "Game", AuditLogService.get_human_readable_table_name("games", :en)
    assert_equal "Игра", AuditLogService.get_human_readable_table_name("games", :ru)
  end

  test "get_human_readable_table_name returns humanized name if translation missing" do
    assert_equal "Unknown table", AuditLogService.get_human_readable_table_name("unknown_table", :en)
  end

  test "get_human_readable_field_name returns translated name" do
    assert_equal "Name", AuditLogService.get_human_readable_field_name("games", "name", :en)
    assert_equal "Название", AuditLogService.get_human_readable_field_name("games", "name", :ru)
  end

  test "get_human_readable_field_name returns humanized name if translation missing" do
    assert_equal "Unknown field", AuditLogService.get_human_readable_field_name("games", "unknown_field", :en)
  end

  test "format_for_api returns formatted hash" do
    audit_log = AuditLog.create!(
      user_id: nil,
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::UPDATE,
      old_values: { "name" => "Old" },
      new_values: { "name" => "New" }
    )

    formatted = AuditLogService.format_for_api(audit_log, :en)

    assert_equal audit_log.id, formatted[:id]
    assert_equal "Game", formatted[:table_name]
    assert_equal "games", formatted[:table_name_raw]
    assert_equal "Updated", formatted[:action_label]
    assert_equal({ "Name" => "Old" }, formatted[:old_values])
    assert_equal({ "Name" => "New" }, formatted[:new_values])
  end

  test "format_for_api uses Russian locale" do
    audit_log = AuditLog.create!(
      user_id: nil,
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::UPDATE,
      old_values: { "name" => "Old" },
      new_values: { "name" => "New" }
    )

    formatted = AuditLogService.format_for_api(audit_log, :ru)

    assert_equal "Игра", formatted[:table_name]
    assert_equal "Обновлено", formatted[:action_label]
    assert_equal({ "Название" => "Old" }, formatted[:old_values])
  end

  test "format_values transforms keys to human readable names" do
    values = { "name" => "Test", "release_year" => 2024 }
    formatted = AuditLogService.format_values(values, "games", :en)

    assert_equal "Test", formatted["Name"]
    assert_equal 2024, formatted["Release Year"]
  end

  test "format_values returns empty hash for nil" do
    assert_equal({}, AuditLogService.format_values(nil, "games", :en))
  end

  test "format_values returns empty hash for empty hash" do
    assert_equal({}, AuditLogService.format_values({}, "games", :en))
  end
end
