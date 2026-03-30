require "test_helper"

class UsersPlaytimeDeleteServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: "TestUser",
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
    @game = Game.create!(name: "Test Game", release_year: 2024)
    @users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: 180
    )
    @admin_user = User.create!(
      username: "AdminUser",
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: USER_ROLES::ADMIN
    )
  end

  test "delete soft deletes users_playtime" do
    result = UsersPlaytimeDeleteService.call(@users_playtime, current_user: @admin_user)

    assert result.is_disabled?
    assert_equal @users_playtime.id, result.id
  end

  test "delete creates audit log" do
    assert_difference "AuditLog.count", 2 do
      UsersPlaytimeDeleteService.call(@users_playtime, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "users_playtimes", record_id: @users_playtime.id, action: AUDIT_ACTIONS::DELETE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_equal "users_playtimes", audit_log.table_name
    assert_equal @users_playtime.id, audit_log.record_id
  end

  test "delete enqueues users playtime recalculation job" do
    game_id = @game.id
    UsersPlaytimeDeleteService.call(@users_playtime, current_user: @admin_user)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: game_id)
    assert recalculation.present?
  end

  test "delete raises error if users_playtime already disabled" do
    @users_playtime.update!(is_disabled: true)

    assert_raises UsersPlaytimeDeleteService::UsersPlaytimeDeleteError do
      UsersPlaytimeDeleteService.call(@users_playtime, current_user: @admin_user)
    end
  end

  test "delete works without current_user" do
    result = UsersPlaytimeDeleteService.call(@users_playtime)

    assert result.is_disabled?
  end
end
