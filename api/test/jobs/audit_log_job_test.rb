require "test_helper"

class AuditLogJobTest < ActiveJob::TestCase
  test "perform creates audit log" do
    assert_difference "AuditLog.count", 1 do
      AuditLogJob.perform_now(
        user_id: nil,
        table_name: "games",
        record_id: 1,
        action: AUDIT_ACTIONS::CREATE,
        old_values: {},
        new_values: { "name" => "Test" }
      )
    end

    audit_log = AuditLog.last
    assert_nil audit_log.user_id
    assert_equal "games", audit_log.table_name
    assert_equal 1, audit_log.record_id
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_equal({ "name" => "Test" }, audit_log.new_values)
  end
end
