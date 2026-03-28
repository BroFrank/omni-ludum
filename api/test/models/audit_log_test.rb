require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  test "should create audit log" do
    audit_log = AuditLog.new(
      user_id: nil,
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE,
      old_values: {},
      new_values: { "name" => "Test Game" }
    )

    assert audit_log.save
  end

  test "should validate presence of table_name" do
    audit_log = AuditLog.new(
      table_name: nil,
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE
    )

    assert_not audit_log.valid?
    assert_includes audit_log.errors[:table_name], "can't be blank"
  end

  test "should validate presence of record_id" do
    audit_log = AuditLog.new(
      table_name: "games",
      record_id: nil,
      action: AUDIT_ACTIONS::CREATE
    )

    assert_not audit_log.valid?
    assert_includes audit_log.errors[:record_id], "can't be blank"
  end

  test "should validate action is valid" do
    audit_log = AuditLog.new(
      table_name: "games",
      record_id: 1,
      action: "INVALID"
    )

    assert_not audit_log.valid?
    assert_includes audit_log.errors[:action], "must be CREATE, UPDATE, or DELETE"
  end

  test "should accept valid actions" do
    [ AUDIT_ACTIONS::CREATE, AUDIT_ACTIONS::UPDATE, AUDIT_ACTIONS::DELETE ].each do |valid_action|
      audit_log = AuditLog.new(
        table_name: "games",
        record_id: 1,
        action: valid_action
      )

      assert audit_log.valid?, "Action #{valid_action} should be valid"
    end
  end

  test "should belong to user" do
    audit_log = AuditLog.reflect_on_association(:user)
    assert_equal :belongs_to, audit_log.macro
  end

  test "should have default empty hash for old_values" do
    audit_log = AuditLog.create!(
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE
    )

    assert_equal({}, audit_log.old_values)
  end

  test "should have default empty hash for new_values" do
    audit_log = AuditLog.create!(
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE
    )

    assert_equal({}, audit_log.new_values)
  end

  test "should scope by action" do
    create_audit_log = AuditLog.create!(
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE
    )
    update_audit_log = AuditLog.create!(
      table_name: "games",
      record_id: 2,
      action: AUDIT_ACTIONS::UPDATE
    )

    create_logs = AuditLog.by_action(AUDIT_ACTIONS::CREATE)
    update_logs = AuditLog.by_action(AUDIT_ACTIONS::UPDATE)

    assert_includes create_logs, create_audit_log
    assert_not_includes create_logs, update_audit_log
    assert_includes update_logs, update_audit_log
    assert_not_includes update_logs, create_audit_log
  end

  test "should scope by table_name" do
    game_log = AuditLog.create!(
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE
    )
    user_log = AuditLog.create!(
      table_name: "users",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE
    )

    game_logs = AuditLog.by_table("games")
    user_logs = AuditLog.by_table("users")

    assert_includes game_logs, game_log
    assert_not_includes game_logs, user_log
    assert_includes user_logs, user_log
    assert_not_includes user_logs, game_log
  end

  test "should scope by user_id" do
    user1_log = AuditLog.create!(
      user_id: nil,
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE
    )
    user2_log = AuditLog.create!(
      user_id: nil,
      table_name: "games",
      record_id: 2,
      action: AUDIT_ACTIONS::CREATE
    )

    user1_logs = AuditLog.by_user(nil)
    user2_logs = AuditLog.by_user(nil)

    assert_includes user1_logs, user1_log
    assert_includes user2_logs, user2_log
  end

  test "should scope recent first" do
    old_log = AuditLog.create!(
      table_name: "games",
      record_id: 1,
      action: AUDIT_ACTIONS::CREATE,
      created_at: 1.day.ago
    )
    new_log = AuditLog.create!(
      table_name: "games",
      record_id: 2,
      action: AUDIT_ACTIONS::CREATE,
      created_at: Time.current
    )

    recent_logs = AuditLog.recent

    assert_equal new_log, recent_logs.first
    assert_equal old_log, recent_logs.last
  end
end
