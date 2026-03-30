require "test_helper"

class GenreDisableServiceTest < ActiveSupport::TestCase
  setup do
    @genre = Genre.create!(
      name: "Test Genre",
      slug: "test-genre"
    )
    @admin_user = User.create!(
      username: "AdminUser",
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: USER_ROLES::ADMIN
    )
  end

  test "disable soft deletes genre" do
    result = GenreDisableService.call(@genre, current_user: @admin_user)

    assert result.is_disabled?
    assert_equal @genre.id, result.id
  end

  test "disable soft deletes associated game_genres" do
    game = Game.create!(name: "Test Game", release_year: 2024)
    game_genre = GameGenre.create!(game: game, genre: @genre)

    GenreDisableService.call(@genre, current_user: @admin_user)

    assert game_genre.reload.is_disabled?
  end

  test "disable creates audit log" do
    assert_difference "AuditLog.count", 2 do
      GenreDisableService.call(@genre, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "genres", record_id: @genre.id, action: AUDIT_ACTIONS::DELETE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::DELETE, audit_log.action
    assert_equal "genres", audit_log.table_name
    assert_equal @genre.id, audit_log.record_id
  end

  test "disable raises error if genre already disabled" do
    @genre.update!(is_disabled: true)

    assert_raises GenreDisableService::GenreDisableError do
      GenreDisableService.call(@genre, current_user: @admin_user)
    end
  end

  test "restore re-enables disabled genre" do
    @genre.update!(is_disabled: true)
    result = GenreDisableService.restore(@genre, current_user: @admin_user)

    assert_not result.is_disabled?
  end

  test "restore raises error if genre not disabled" do
    assert_raises GenreDisableService::GenreDisableError do
      GenreDisableService.restore(@genre, current_user: @admin_user)
    end
  end

  test "restore creates audit log" do
    @genre.update!(is_disabled: true)

    assert_difference "AuditLog.count", 2 do
      GenreDisableService.restore(@genre, current_user: @admin_user)
    end

    audit_log = AuditLog.where(table_name: "genres", record_id: @genre.id, action: AUDIT_ACTIONS::CREATE).last
    assert audit_log.present?
    assert_equal AUDIT_ACTIONS::CREATE, audit_log.action
    assert_equal "genres", audit_log.table_name
  end
end
