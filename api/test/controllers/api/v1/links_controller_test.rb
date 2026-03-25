require "test_helper"

class Api::V1::LinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:one)
    @valid_link_attrs = {
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Official Trailer"
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/links (index)
  # ============================================
  test "GET /api/v1/links returns list of active links" do
    link1 = Link.create!(@valid_link_attrs.merge(game: @game, title: "Link 1"))
    link2 = Link.create!(@valid_link_attrs.merge(game: @game, title: "Link 2"))

    get api_v1_links_url, as: :json

    assert_response :success
    assert json_response.any? { |l| l["id"] == link1.id }
    assert json_response.any? { |l| l["id"] == link2.id }
  end

  test "GET /api/v1/links does not return disabled links" do
    active_link = Link.create!(@valid_link_attrs.merge(game: @game, title: "Active Link"))
    disabled_link = Link.create!(@valid_link_attrs.merge(game: @game, title: "Disabled", is_disabled: true))

    get api_v1_links_url, as: :json

    assert_response :success
    assert json_response.any? { |l| l["id"] == active_link.id }
    assert_not json_response.any? { |l| l["id"] == disabled_link.id }
  end

  test "GET /api/v1/links supports pagination" do
    25.times { |i| Link.create!(@valid_link_attrs.merge(game: @game, title: "Link #{i}")) }

    get api_v1_links_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  test "GET /api/v1/links returns empty array when no links" do
    Link.where(game: @game).destroy_all

    get api_v1_links_url, as: :json

    assert_response :success
    assert_equal 0, json_response.count
  end

  # ============================================
  # GET /api/v1/games/:game_id/links (nested index)
  # ============================================
  test "GET /api/v1/games/:game_id/links returns links for specific game" do
    game1 = @game
    game2 = games(:two)

    link1 = Link.create!(@valid_link_attrs.merge(game: game1, title: "Game 1 Link"))
    link2 = Link.create!(@valid_link_attrs.merge(game: game2, title: "Game 2 Link"))

    get api_v1_game_links_url(game1.name), as: :json

    assert_response :success
    assert json_response.any? { |l| l["id"] == link1.id }
    assert_not json_response.any? { |l| l["id"] == link2.id }
  end

  test "GET /api/v1/games/:game_id/links returns 404 for non-existent game" do
    get api_v1_game_links_url("Nonexistent"), as: :json

    assert_response :not_found
  end

  # ============================================
  # GET /api/v1/links/:id (show)
  # ============================================
  test "GET /api/v1/links/:id returns link by id" do
    link = Link.create!(@valid_link_attrs.merge(game: @game))

    get api_v1_link_url(link.id), as: :json

    assert_response :success
    assert_equal link.id, json_response["id"]
    assert_equal link.title, json_response["title"]
  end

  test "GET /api/v1/links/:id returns 404 for non-existent link" do
    get api_v1_link_url(999999), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/links (create)
  # ============================================
  test "POST /api/v1/links creates link successfully" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(game_id: @game.id)
    }, as: :json

    assert_response :created
    assert_equal "Official Trailer", json_response["title"]
    assert_equal "TRAILER", json_response["link_type"]
  end

  test "POST /api/v1/games/:game_id/links creates link for game" do
    post api_v1_game_links_url(@game.name), params: {
      link: @valid_link_attrs
    }, as: :json

    assert_response :created
    assert_equal @game.id, json_response["game_id"]
    assert_equal "Official Trailer", json_response["title"]
  end

  test "POST /api/v1/games/:game_id/links returns 404 for non-existent game" do
    post api_v1_game_links_url("Nonexistent"), params: {
      link: @valid_link_attrs
    }, as: :json

    assert_response :not_found
  end

  test "POST /api/v1/links normalizes link_type to uppercase" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(link_type: "trailer", game_id: @game.id)
    }, as: :json

    assert_response :created
    assert_equal "TRAILER", json_response["link_type"]
  end

  test "POST /api/v1/links with invalid link_type returns error" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(link_type: "INVALID", game_id: @game.id)
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any? { |e| e.include?("link type") }
  end

  test "POST /api/v1/links with invalid URL returns error" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(url: "not-a-url", game_id: @game.id)
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any? { |e| e.include?("URL") }
  end

  test "POST /api/v1/links with missing title returns error" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(title: nil, game_id: @game.id)
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any? { |e| e.include?("Title") }
  end

  test "POST /api/v1/links with missing game_id returns error" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(game_id: nil)
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any? { |e| e.include?("Game") }
  end

  # ============================================
  # PATCH /api/v1/links/:id (update)
  # ============================================
  test "PATCH /api/v1/links/:id updates link successfully" do
    link = Link.create!(@valid_link_attrs.merge(game: @game))

    patch api_v1_link_url(link.id), params: {
      link: { title: "Updated Title" }
    }, as: :json

    assert_response :success
    assert_equal "Updated Title", json_response["title"]
  end

  test "PATCH /api/v1/links/:id returns 404 for non-existent link" do
    patch api_v1_link_url(999999), params: {
      link: { title: "Updated Title" }
    }, as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/links/:id can update url" do
    link = Link.create!(@valid_link_attrs.merge(game: @game))

    patch api_v1_link_url(link.id), params: {
      link: { url: "https://www.youtube.com/watch?v=new_video" }
    }, as: :json

    assert_response :success
    assert_equal "https://www.youtube.com/watch?v=new_video", json_response["url"]
  end

  test "PATCH /api/v1/links/:id can update link_type" do
    link = Link.create!(@valid_link_attrs.merge(game: @game))

    patch api_v1_link_url(link.id), params: {
      link: { link_type: "LONGPLAY" }
    }, as: :json

    assert_response :success
    assert_equal "LONGPLAY", json_response["link_type"]
  end

  test "PATCH /api/v1/links/:id with invalid data returns error" do
    link = Link.create!(@valid_link_attrs.merge(game: @game))

    patch api_v1_link_url(link.id), params: {
      link: { title: nil }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any? { |e| e.include?("Title") }
  end

  # ============================================
  # DELETE /api/v1/links/:id (destroy - soft delete)
  # ============================================
  test "DELETE /api/v1/links/:id soft deletes link" do
    link = Link.create!(@valid_link_attrs.merge(game: @game))

    delete api_v1_link_url(link.id), as: :json

    assert_response :no_content
    assert link.reload.is_disabled
  end

  test "DELETE /api/v1/links/:id returns 404 for non-existent link" do
    delete api_v1_link_url(999999), as: :json

    assert_response :not_found
  end

  test "DELETE /api/v1/links/:id does not destroy the record, just disables it" do
    link = Link.create!(@valid_link_attrs.merge(game: @game))

    assert_difference -> { Link.count }, 0 do
      delete api_v1_link_url(link.id), as: :json
    end
  end

  # ============================================
  # Link type tests
  # ============================================
  test "POST /api/v1/links with LONGPLAY type" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(link_type: LINK_TYPES::LONGPLAY, game_id: @game.id)
    }, as: :json

    assert_response :created
    assert_equal "LONGPLAY", json_response["link_type"]
  end

  test "POST /api/v1/links with SPEEDRUN type" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(link_type: LINK_TYPES::SPEEDRUN, game_id: @game.id)
    }, as: :json

    assert_response :created
    assert_equal "SPEEDRUN", json_response["link_type"]
  end

  test "POST /api/v1/links with OTHER type" do
    post api_v1_links_url, params: {
      link: @valid_link_attrs.merge(link_type: LINK_TYPES::OTHER, game_id: @game.id)
    }, as: :json

    assert_response :created
    assert_equal "OTHER", json_response["link_type"]
  end
end
