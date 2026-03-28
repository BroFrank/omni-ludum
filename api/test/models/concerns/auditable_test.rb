require "test_helper"

class AuditableTest < ActiveSupport::TestCase
  setup do
    @original_user_id = Thread.current[:current_user_id]
    Thread.current[:current_user_id] = nil
  end

  teardown do
    Thread.current[:current_user_id] = @original_user_id
  end

  test "should create audit log on record creation" do
    assert_difference "AuditLog.count", 1 do
      User.create!(
        username: "testuser#{Time.current.to_i}",
        email: "test#{Time.current.to_i}@example.com",
        password: "Test123!@#"
      )
    end

    audit_log = AuditLog.last
    assert_equal "users", audit_log.table_name
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_nil audit_log.user_id
    assert audit_log.new_values.key?("username")
    assert audit_log.new_values.key?("email")
  end

  test "should create audit log on record update" do
    user = User.create!(
      username: "testuserupd#{Time.current.to_i}",
      email: "testupd#{Time.current.to_i}@example.com",
      password: "Test123!@#"
    )

    AuditLog.delete_all

    assert_difference "AuditLog.count", 1 do
      user.update!(email: "newupd#{Time.current.to_i}@example.com")
    end

    audit_log = AuditLog.last
    assert_equal "users", audit_log.table_name
    assert_equal AUDIT_ACTIONS::UPDATE, audit_log.action
    assert_nil audit_log.user_id
    assert audit_log.old_values.key?("email")
    assert audit_log.new_values.key?("email")
  end

  test "should not create audit log on update with no changes" do
    user = User.create!(
      username: "testusertouch#{Time.current.to_i}",
      email: "testtouch#{Time.current.to_i}@example.com",
      password: "Test123!@#"
    )

    AuditLog.delete_all

    assert_no_difference "AuditLog.count" do
      user.touch(:updated_at)
    end
  end

  test "should create audit log on soft delete" do
    user = User.create!(
      username: "testuserdel#{Time.current.to_i}",
      email: "testdel#{Time.current.to_i}@example.com",
      password: "Test123!@#"
    )

    AuditLog.delete_all

    assert_difference "AuditLog.count", 1 do
      user.update!(is_disabled: true)
    end

    audit_log = AuditLog.last
    assert_equal "users", audit_log.table_name
    assert_equal AUDIT_ACTIONS::UPDATE, audit_log.action
    assert_nil audit_log.user_id
    assert_equal false, audit_log.old_values["is_disabled"]
    assert_equal true, audit_log.new_values["is_disabled"]
  end

  test "should create audit log on record destroy" do
    game = Game.create!(name: "Test Game #{Time.current.to_i}", release_year: 2024)

    AuditLog.delete_all

    assert_difference "AuditLog.count", 1 do
      game.destroy!
    end

    audit_log = AuditLog.last
    assert_equal "games", audit_log.table_name
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_nil audit_log.user_id
    assert_equal "Test Game #{Time.current.to_i}", audit_log.old_values["name"]
  end

  test "should handle nil user_id" do
    Thread.current[:current_user_id] = nil

    assert_difference "AuditLog.count", 1 do
      User.create!(
        username: "testusernil#{Time.current.to_i}",
        email: "testnil#{Time.current.to_i}@example.com",
        password: "Test123!@#"
      )
    end

    audit_log = AuditLog.last
    assert_nil audit_log.user_id
  end
end
