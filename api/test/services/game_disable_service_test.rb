require "test_helper"

class GameDisableServiceTest < ActiveSupport::TestCase
  setup do
    @game = Game.create!(name: "Test Game", release_year: 2024)
    @admin_user = User.create!(
      username: "AdminUser",
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: USER_ROLES::ADMIN
    )
  end

  test "disable soft deletes game" do
    result = GameDisableService.call(@game, current_user: @admin_user)

    assert result.is_disabled?
    assert_equal @game.id, result.id
  end

  test "disable nullifies base_game_id for associated DLCs" do
    dlc = Game.create!(
      name: "Test DLC",
      release_year: 2024,
      is_dlc: true,
      base_game_id: @game.id
    )

    GameDisableService.call(@game, current_user: @admin_user)

    assert dlc.reload.base_game_id.nil?
  end

  test "disable nullifies associated reviews" do
    user = User.create!(
      username: "Reviewer",
      email: "reviewer@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
    review = Review.create!(
      user: user,
      game: @game,
      rating: 8,
      difficulty: 5
    )

    GameDisableService.call(@game, current_user: @admin_user)

    assert review.reload.is_disabled?
  end

  test "disable nullifies associated users_playtimes" do
    user = User.create!(
      username: "Player",
      email: "player@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
    playtime = UsersPlaytime.create!(
      user: user,
      game: @game,
      minutes_regular: 120
    )

    GameDisableService.call(@game, current_user: @admin_user)

    assert playtime.reload.is_disabled?
  end

  test "disable creates audit log" do
    assert_difference "AuditLog.count", 2 do
      GameDisableService.call(@game, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "games", record_id: @game.id, action: AUDIT_ACTIONS::DELETE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_equal "games", audit_log.table_name
    assert_equal @game.id, audit_log.record_id
  end

  test "disable raises error if game already disabled" do
    @game.update!(is_disabled: true)

    assert_raises GameDisableService::GameDisableError do
      GameDisableService.call(@game, current_user: @admin_user)
    end
  end

  test "restore re-enables disabled game" do
    @game.update!(is_disabled: true)
    result = GameDisableService.restore(@game, current_user: @admin_user)

    assert_not result.is_disabled?
  end

  test "restore raises error if game not disabled" do
    assert_raises GameDisableService::GameDisableError do
      GameDisableService.restore(@game, current_user: @admin_user)
    end
  end

  test "restore creates audit log" do
    @game.update!(is_disabled: true)

    assert_difference "AuditLog.count", 2 do
      GameDisableService.restore(@game, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "games", record_id: @game.id, action: AUDIT_ACTIONS::CREATE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_equal "games", audit_log.table_name
  end
end
