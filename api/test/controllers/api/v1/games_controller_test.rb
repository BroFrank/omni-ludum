require "test_helper"

class Api::V1::GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clean up any games created by previous tests
    Game.delete_all

    @valid_game_attrs = {
      name: "Test Game",
      release_year: 2020
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/games (index)
  # ============================================
  test "GET /api/v1/games returns list of active games" do
    game1 = Game.create!(@valid_game_attrs)
    game2 = Game.create!(@valid_game_attrs.merge(name: "Game 2"))

    get api_v1_games_url, as: :json

    assert_response :success
    assert_equal 2, json_response.count
  end

  test "GET /api/v1/games does not return disabled games" do
    active_game = Game.create!(@valid_game_attrs)
    disabled_game = Game.create!(@valid_game_attrs.merge(name: "Disabled Game", is_disabled: true))

    get api_v1_games_url, as: :json

    assert_response :success
    assert json_response.any? { |g| g["id"] == active_game.id }
    assert_not json_response.any? { |g| g["id"] == disabled_game.id }
  end

  test "GET /api/v1/games supports pagination" do
    25.times { |i| Game.create!(@valid_game_attrs.merge(name: "Game #{i}")) }

    get api_v1_games_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  test "GET /api/v1/games returns empty array when no games" do
    get api_v1_games_url, as: :json

    assert_response :success
    assert_equal 0, json_response.count
  end

  # ============================================
  # GET /api/v1/games/:id (show)
  # ============================================
  test "GET /api/v1/games/:id returns game by name" do
    game = Game.create!(@valid_game_attrs)

    get api_v1_game_url(game.name), as: :json

    assert_response :success
    assert_equal game.id, json_response["id"]
  end

  test "GET /api/v1/games/:id returns 404 for non-existent game" do
    get api_v1_game_url("Nonexistent"), as: :json

    assert_response :not_found
  end

  test "GET /api/v1/games/:id returns 404 for disabled game" do
    game = Game.create!(@valid_game_attrs.merge(is_disabled: true))

    get api_v1_game_url(game.name), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/games (create)
  # ============================================
  test "POST /api/v1/games creates game successfully" do
    post api_v1_games_url, params: { game: @valid_game_attrs }, as: :json

    assert_response :created
    assert_equal "Test Game", json_response["name"]
  end

  test "POST /api/v1/games sets default values for boolean fields" do
    post api_v1_games_url, params: { game: @valid_game_attrs }, as: :json

    assert_response :created
    assert_equal false, json_response["is_dlc"]
    assert_equal false, json_response["is_mod"]
    assert_equal false, json_response["is_disabled"]
  end

  test "POST /api/v1/games returns validation errors" do
    post api_v1_games_url, params: {
      game: { name: nil }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/games creates game with platform_id" do
    platform = Platform.create!(name: "PC", slug: "pc")

    post api_v1_games_url, params: {
      game: @valid_game_attrs.merge(platform_id: platform.id)
    }, as: :json

    assert_response :created
    assert_equal platform.id, json_response["platform_id"]
  end

  test "POST /api/v1/games creates game without platform_id" do
    post api_v1_games_url, params: {
      game: @valid_game_attrs
    }, as: :json

    assert_response :created
    assert_nil json_response["platform_id"]
  end

  test "POST /api/v1/games with same name on different platforms is successful" do
    platform1 = Platform.create!(name: "PC", slug: "pc")
    platform2 = Platform.create!(name: "PlayStation", slug: "playstation")

    Game.create!(@valid_game_attrs.merge(platform: platform1))

    post api_v1_games_url, params: {
      game: @valid_game_attrs.merge(platform_id: platform2.id, release_year: 2021)
    }, as: :json

    assert_response :created
    assert_equal platform2.id, json_response["platform_id"]
  end

  test "POST /api/v1/games creates game with all fields" do
    post api_v1_games_url, params: {
      game: {
        name: "Complete Game",
        release_year: 2021,
        rating_avg: 8.5,
        difficulty_avg: 6.0,
        playtime_avg: 120,
        playtime_100_avg: 360,
        is_dlc: true,
        is_mod: false
      }
    }, as: :json

    assert_response :created
    assert_equal "Complete Game", json_response["name"]
    assert_equal 2021, json_response["release_year"]
    assert_equal 8.5, json_response["rating_avg"]
    assert_equal 6.0, json_response["difficulty_avg"]
    assert_equal 120, json_response["playtime_avg"]
    assert_equal 360, json_response["playtime_100_avg"]
    assert json_response["is_dlc"]
    assert_not json_response["is_mod"]
  end

  # ============================================
  # PATCH /api/v1/games/:id (update)
  # ============================================
  test "PATCH /api/v1/games/:id updates game successfully" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { name: "Updated Game" }
    }, as: :json

    assert_response :success
    assert_equal "Updated Game", json_response["name"]
  end

  test "PATCH /api/v1/games/:id returns 404 for non-existent game" do
    patch api_v1_game_url("Nonexistent"), params: {
      game: { name: "Updated Game" }
    }, as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/games/:id returns validation errors" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { name: nil }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any? { |e| e.include?("Name") }
  end

  test "PATCH /api/v1/games/:id can update release_year" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { release_year: 2022 }
    }, as: :json

    assert_response :success
    assert_equal 2022, json_response["release_year"]
  end

  test "PATCH /api/v1/games/:id can update rating_avg" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { rating_avg: 9.0 }
    }, as: :json

    assert_response :success
    assert_equal 9.0, json_response["rating_avg"]
  end

  test "PATCH /api/v1/games/:id can update difficulty_avg" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { difficulty_avg: 7.5 }
    }, as: :json

    assert_response :success
    assert_equal 7.5, json_response["difficulty_avg"]
  end

  test "PATCH /api/v1/games/:id can update playtime_avg" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { playtime_avg: 180 }
    }, as: :json

    assert_response :success
    assert_equal 180, json_response["playtime_avg"]
  end

  test "PATCH /api/v1/games/:id can update playtime_100_avg" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { playtime_100_avg: 420 }
    }, as: :json

    assert_response :success
    assert_equal 420, json_response["playtime_100_avg"]
  end

  test "PATCH /api/v1/games/:id can update is_dlc" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { is_dlc: true }
    }, as: :json

    assert_response :success
    assert json_response["is_dlc"]
  end

  test "PATCH /api/v1/games/:id can update is_mod" do
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { is_mod: true }
    }, as: :json

    assert_response :success
    assert json_response["is_mod"]
  end

  test "PATCH /api/v1/games/:id can update base_game_id" do
    base_game = Game.create!(@valid_game_attrs)
    dlc = Game.create!(@valid_game_attrs.merge(name: "DLC Game"))

    patch api_v1_game_url(dlc.name), params: {
      game: { base_game_id: base_game.id }
    }, as: :json

    assert_response :success
    assert_equal base_game.id, json_response["base_game_id"]
  end

  test "PATCH /api/v1/games/:id can update platform_id" do
    platform = Platform.create!(name: "PC", slug: "pc")
    game = Game.create!(@valid_game_attrs)

    patch api_v1_game_url(game.name), params: {
      game: { platform_id: platform.id }
    }, as: :json

    assert_response :success
    assert_equal platform.id, json_response["platform_id"]
  end

  # ============================================
  # PATCH /api/v1/games/:id/disable (disable)
  # ============================================
  test "PATCH /api/v1/games/:id/disable disables game successfully" do
    game = Game.create!(@valid_game_attrs)

    patch disable_api_v1_game_url(game.name), as: :json

    assert_response :success
    assert json_response["is_disabled"]
  end

  test "PATCH /api/v1/games/:id/disable returns 404 for non-existent game" do
    patch disable_api_v1_game_url("Nonexistent"), as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/games/:id/disable sets is_disabled to true" do
    game = Game.create!(@valid_game_attrs)

    patch disable_api_v1_game_url(game.name), as: :json

    assert_response :success
    game.reload
    assert game.is_disabled
  end

  test "PATCH /api/v1/games/:id/disable does not affect other games" do
    game1 = Game.create!(@valid_game_attrs)
    game2 = Game.create!(@valid_game_attrs.merge(name: "Game 2"))

    patch disable_api_v1_game_url(game1.name), as: :json

    assert_response :success
    assert game1.reload.is_disabled
    assert_not game2.reload.is_disabled
  end
end
