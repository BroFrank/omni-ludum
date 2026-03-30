require "test_helper"

class ReviewDeleteServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: "TestUser",
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
    @game = Game.create!(name: "Test Game", release_year: 2024)
    @review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5
    )
    @admin_user = User.create!(
      username: "AdminUser",
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: USER_ROLES::ADMIN
    )
  end

  test "delete soft deletes review" do
    result = ReviewDeleteService.call(@review, current_user: @admin_user)

    assert result.is_disabled?
    assert_equal @review.id, result.id
  end

  test "delete creates audit log" do
    assert_difference "AuditLog.count", 3 do
      ReviewDeleteService.call(@review, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "reviews", record_id: @review.id, action: AUDIT_ACTIONS::DELETE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_equal "reviews", audit_log.table_name
    assert_equal @review.id, audit_log.record_id
  end

  test "delete enqueues game rating recalculation job" do
    game_id = @game.id
    ReviewDeleteService.call(@review, current_user: @admin_user)

    recalculation = GameRatingRecalculation.find_by(game_id: game_id)
    assert recalculation.present?
  end

  test "delete raises error if review already disabled" do
    @review.update!(is_disabled: true)

    assert_raises ReviewDeleteService::ReviewDeleteError do
      ReviewDeleteService.call(@review, current_user: @admin_user)
    end
  end

  test "delete works without current_user" do
    result = ReviewDeleteService.call(@review)

    assert result.is_disabled?
  end
end
