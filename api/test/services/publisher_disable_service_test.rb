require "test_helper"

class PublisherDisableServiceTest < ActiveSupport::TestCase
  setup do
    @publisher = Publisher.create!(
      name: "Test Publisher",
      type: PUBLISHER_TYPES::PUBLISHER
    )
    @admin_user = User.create!(
      username: "AdminUser",
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: USER_ROLES::ADMIN
    )
  end

  test "disable soft deletes publisher" do
    result = PublisherDisableService.call(@publisher, current_user: @admin_user)

    assert result.is_disabled?
    assert_equal @publisher.id, result.id
  end

  test "disable nullifies publisher_id for associated games" do
    game = Game.create!(
      name: "Test Game",
      release_year: 2024,
      publisher_id: @publisher.id
    )

    PublisherDisableService.call(@publisher, current_user: @admin_user)

    assert game.reload.publisher_id.nil?
  end

  test "disable creates audit log" do
    assert_difference "AuditLog.count", 2 do
      PublisherDisableService.call(@publisher, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "publishers", record_id: @publisher.id, action: AUDIT_ACTIONS::DELETE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_equal "publishers", audit_log.table_name
    assert_equal @publisher.id, audit_log.record_id
  end

  test "disable raises error if publisher already disabled" do
    @publisher.update!(is_disabled: true)

    assert_raises PublisherDisableService::PublisherDisableError do
      PublisherDisableService.call(@publisher, current_user: @admin_user)
    end
  end

  test "restore re-enables disabled publisher" do
    @publisher.update!(is_disabled: true)
    result = PublisherDisableService.restore(@publisher, current_user: @admin_user)

    assert_not result.is_disabled?
  end

  test "restore raises error if publisher not disabled" do
    assert_raises PublisherDisableService::PublisherDisableError do
      PublisherDisableService.restore(@publisher, current_user: @admin_user)
    end
  end

  test "restore creates audit log" do
    @publisher.update!(is_disabled: true)

    assert_difference "AuditLog.count", 2 do
      PublisherDisableService.restore(@publisher, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "publishers", record_id: @publisher.id, action: AUDIT_ACTIONS::CREATE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_equal "publishers", audit_log.table_name
  end
end
