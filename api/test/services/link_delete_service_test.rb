require "test_helper"

class LinkDeleteServiceTest < ActiveSupport::TestCase
  setup do
    @game = Game.create!(name: "Test Game", release_year: 2024)
    @link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://example.com/trailer",
      title: "Test Trailer"
    )
    @admin_user = User.create!(
      username: "AdminUser",
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: USER_ROLES::ADMIN
    )
  end

  test "delete soft deletes link" do
    result = LinkDeleteService.call(@link, current_user: @admin_user)

    assert result.is_disabled?
    assert_equal @link.id, result.id
  end

  test "delete creates audit log" do
    assert_difference "AuditLog.count", 2 do
      LinkDeleteService.call(@link, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "links", record_id: @link.id, action: AUDIT_ACTIONS::DELETE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_equal "links", audit_log.table_name
    assert_equal @link.id, audit_log.record_id
  end

  test "delete raises error if link already disabled" do
    @link.update!(is_disabled: true)

    assert_raises LinkDeleteService::LinkDeleteError do
      LinkDeleteService.call(@link, current_user: @admin_user)
    end
  end

  test "restore re-enables disabled link" do
    @link.update!(is_disabled: true)
    result = LinkDeleteService.restore(@link, current_user: @admin_user)

    assert_not result.is_disabled?
  end

  test "restore raises error if link not disabled" do
    assert_raises LinkDeleteService::LinkDeleteError do
      LinkDeleteService.restore(@link, current_user: @admin_user)
    end
  end

  test "restore creates audit log" do
    @link.update!(is_disabled: true)

    assert_difference "AuditLog.count", 2 do
      LinkDeleteService.restore(@link, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "links", record_id: @link.id, action: AUDIT_ACTIONS::CREATE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_equal "links", audit_log.table_name
  end

  test "delete works without current_user" do
    result = LinkDeleteService.call(@link)

    assert result.is_disabled?
  end
end
