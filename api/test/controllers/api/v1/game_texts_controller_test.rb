require "test_helper"

class Api::V1::GameTextsControllerTest < ActionDispatch::IntegrationTest
  setup do
    GameText.delete_all
    @game = Game.create!(name: "Test Game", release_year: 2024)
    @valid_attrs = {
      game_id: @game.id,
      lang_code: "en",
      description: "Test description",
      trivia: "Test trivia"
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/game_texts (index)
  # ============================================
  test "GET /api/v1/game_texts returns list of game texts" do
    GameText.create!(@valid_attrs)
    GameText.create!(@valid_attrs.merge(lang_code: "ru", description: "Русское описание"))

    get api_v1_game_texts_url, as: :json

    assert_response :success
    assert_equal 2, json_response.count
  end

  test "GET /api/v1/game_texts supports pagination" do
    25.times do |i|
      game = Game.create!(name: "Game #{i}", release_year: 2024 - i)
      GameText.create!(game: game, lang_code: "en", description: "Desc #{i}")
    end

    get api_v1_game_texts_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  # ============================================
  # GET /api/v1/games/:game_id/game_texts (index)
  # ============================================
  test "GET /api/v1/games/:game_id/game_texts returns texts for specific game" do
    game2 = Game.create!(name: "Another Game", release_year: 2023)
    gt1 = GameText.create!(@valid_attrs)
    gt2 = GameText.create!(@valid_attrs.merge(game: game2, lang_code: "ru"))

    get api_v1_game_game_texts_url(@game.name), as: :json

    assert_response :success
    assert_equal 1, json_response.count
    assert_equal gt1.id, json_response.first["id"]
  end

  test "GET /api/v1/games/:game_id/game_texts returns 404 for non-existent game" do
    get api_v1_game_game_texts_url("nonexistent"), as: :json

    assert_response :not_found
  end

  # ============================================
  # GET /api/v1/game_texts/:id (show)
  # ============================================
  test "GET /api/v1/game_texts/:id returns game text by id" do
    gt = GameText.create!(@valid_attrs)

    get api_v1_game_text_url(gt.id), as: :json

    assert_response :success
    assert_equal gt.id, json_response["id"]
  end

  test "GET /api/v1/game_texts/:id returns 404 for non-existent text" do
    get api_v1_game_text_url(999999), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/game_texts (create)
  # ============================================
  test "POST /api/v1/game_texts creates game text successfully" do
    post api_v1_game_texts_url, params: { game_text: @valid_attrs }, as: :json

    assert_response :created
    assert_equal "Test description", json_response["description"]
    assert_equal "Test trivia", json_response["trivia"]
  end

  test "POST /api/v1/game_texts normalizes lang_code to lowercase" do
    post api_v1_game_texts_url, params: {
      game_text: @valid_attrs.merge(lang_code: "EN")
    }, as: :json

    assert_response :created
    assert_equal "en", json_response["lang_code"]
  end

  test "POST /api/v1/game_texts returns validation errors for invalid lang_code" do
    post api_v1_game_texts_url, params: {
      game_text: @valid_attrs.merge(lang_code: "invalid")
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/game_texts returns validation errors for missing game_id" do
    post api_v1_game_texts_url, params: {
      game_text: { lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/game_texts returns 422 for non-existent game" do
    post api_v1_game_texts_url, params: {
      game_text: { game_id: 999999, lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :unprocessable_entity
    assert_includes json_response["errors"].join, "Game must exist"
  end

  # ============================================
  # POST /api/v1/games/:game_id/game_texts (create)
  # ============================================
  test "POST /api/v1/games/:game_id/game_texts creates text for game" do
    post api_v1_game_game_texts_url(@game.name), params: {
      game_text: { game_id: @game.id, lang_code: "en", description: "Test description", trivia: "Test trivia" }
    }, as: :json

    assert_response :created
    assert_equal "Test description", json_response["description"]
    assert_equal @game.id, json_response["game_id"]
  end

  test "POST /api/v1/games/:game_id/game_texts returns 404 for non-existent game" do
    post api_v1_game_game_texts_url("nonexistent"), params: {
      game_text: { lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :not_found
  end

  # ============================================
  # PATCH /api/v1/game_texts/:id (update)
  # ============================================
  test "PATCH /api/v1/game_texts/:id updates game text successfully" do
    gt = GameText.create!(@valid_attrs)

    patch api_v1_game_text_url(gt.id), params: {
      game_text: { description: "Updated description" }
    }, as: :json

    assert_response :success
    assert_equal "Updated description", json_response["description"]
  end

  test "PATCH /api/v1/game_texts/:id updates trivia successfully" do
    gt = GameText.create!(@valid_attrs)

    patch api_v1_game_text_url(gt.id), params: {
      game_text: { trivia: "Updated trivia" }
    }, as: :json

    assert_response :success
    assert_equal "Updated trivia", json_response["trivia"]
  end

  test "PATCH /api/v1/game_texts/:id returns 404 for non-existent text" do
    patch api_v1_game_text_url(999999), params: {
      game_text: { description: "Updated" }
    }, as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/game_texts/:id returns validation errors" do
    gt = GameText.create!(@valid_attrs)

    patch api_v1_game_text_url(gt.id), params: {
      game_text: { lang_code: "invalid" }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  # ============================================
  # DELETE /api/v1/game_texts/:id (destroy)
  # ============================================
  test "DELETE /api/v1/game_texts/:id deletes game text" do
    gt = GameText.create!(@valid_attrs)

    delete api_v1_game_text_url(gt.id), as: :json

    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      GameText.find(gt.id)
    end
  end

  test "DELETE /api/v1/game_texts/:id returns 404 for non-existent text" do
    delete api_v1_game_text_url(999999), as: :json

    assert_response :not_found
  end
end
