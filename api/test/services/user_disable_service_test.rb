require "test_helper"

class UserDisableServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: "TestUser",
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
    @admin_user = User.create!(
      username: "AdminUser",
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: USER_ROLES::ADMIN
    )
  end

  test "disable soft deletes user" do
    result = UserDisableService.call(@user, current_user: @admin_user)

    assert result.is_disabled?
    assert_equal @user.id, result.id
  end

  test "disable nullifies associated reviews" do
    game = Game.create!(name: "Test Game", release_year: 2024)
    review = Review.create!(
      user: @user,
      game: game,
      rating: 8,
      difficulty: 5
    )

    UserDisableService.call(@user, current_user: @admin_user)

    assert review.reload.is_disabled?
  end

  test "disable nullifies associated users_playtimes" do
    game = Game.create!(name: "Test Game", release_year: 2024)
    playtime = UsersPlaytime.create!(
      user: @user,
      game: game,
      minutes_regular: 120
    )

    UserDisableService.call(@user, current_user: @admin_user)

    assert playtime.reload.is_disabled?
  end

  test "disable creates audit log" do
    assert_difference "AuditLog.count", 2 do
      UserDisableService.call(@user, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "users", record_id: @user.id, action: AUDIT_ACTIONS::DELETE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_equal "users", audit_log.table_name
    assert_equal @user.id, audit_log.record_id
    assert_equal @admin_user.id, audit_log.user_id
  end

  test "disable raises error if user already disabled" do
    @user.update!(is_disabled: true)

    assert_raises UserDisableService::UserDisableError do
      UserDisableService.call(@user, current_user: @admin_user)
    end
  end

  test "restore re-enables disabled user" do
    @user.update!(is_disabled: true)
    result = UserDisableService.restore(@user, current_user: @admin_user)

    assert_not result.is_disabled?
  end

  test "restore raises error if user not disabled" do
    assert_raises UserDisableService::UserDisableError do
      UserDisableService.restore(@user, current_user: @admin_user)
    end
  end

  test "restore creates audit log" do
    @user.update!(is_disabled: true)

    assert_difference "AuditLog.count", 2 do
      UserDisableService.restore(@user, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "users", record_id: @user.id, action: AUDIT_ACTIONS::CREATE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_equal "users", audit_log.table_name
  end

  test "disable works without current_user" do
    result = UserDisableService.call(@user)

    assert result.is_disabled?
  end
end
