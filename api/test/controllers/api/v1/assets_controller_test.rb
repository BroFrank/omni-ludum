require "test_helper"

class Api::V1::AssetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:one)
    @game2 = games(:two)
    @asset = assets(:cover_one)

    @test_file = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/test_image.png"),
      "image/png"
    )
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/games/:game_id/assets (index)
  # ============================================
  test "GET /api/v1/games/:game_id/assets returns list of active assets" do
    Asset.delete_all
    asset = Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: "assets/test.png",
      mime_type: "image/png",
      file_size: 1024
    )

    get api_v1_game_assets_url(@game.name), as: :json

    assert_response :success
    assert_equal 1, json_response.count
    assert_equal asset.id, json_response.first["id"]
  end

  test "GET /api/v1/games/:game_id/assets does not return disabled assets" do
    Asset.delete_all
    active_asset = Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: "assets/active.png",
      mime_type: "image/png",
      file_size: 1024
    )
    disabled_asset = Asset.create!(
      game: @game,
      asset_type: "SCREENSHOT",
      storage_path: "assets/disabled.png",
      mime_type: "image/png",
      file_size: 1024,
      is_disabled: true
    )

    get api_v1_game_assets_url(@game.name), as: :json

    assert_response :success
    assert json_response.any? { |a| a["id"] == active_asset.id }
    assert_not json_response.any? { |a| a["id"] == disabled_asset.id }
  end

  test "GET /api/v1/games/:game_id/assets supports pagination" do
    Asset.delete_all
    25.times do |i|
      Asset.create!(
        game: @game,
        asset_type: "SCREENSHOT",
        storage_path: "assets/screenshot#{i}.png",
        mime_type: "image/png",
        file_size: 1024 * (i + 1),
        order_index: i
      )
    end

    get api_v1_game_assets_url(@game.name), as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  test "GET /api/v1/games/:game_id/assets returns 404 for non-existent game" do
    get api_v1_game_assets_url("Nonexistent"), as: :json

    assert_response :not_found
  end

  test "GET /api/v1/games/:game_id/assets returns assets ordered by order_index" do
    Asset.delete_all
    asset3 = Asset.create!(
      game: @game,
      asset_type: "SCREENSHOT",
      storage_path: "assets/screenshot3.png",
      mime_type: "image/png",
      file_size: 1024,
      order_index: 2
    )
    asset1 = Asset.create!(
      game: @game,
      asset_type: "SCREENSHOT",
      storage_path: "assets/screenshot1.png",
      mime_type: "image/png",
      file_size: 1024,
      order_index: 0
    )
    asset2 = Asset.create!(
      game: @game,
      asset_type: "SCREENSHOT",
      storage_path: "assets/screenshot2.png",
      mime_type: "image/png",
      file_size: 1024,
      order_index: 1
    )

    get api_v1_game_assets_url(@game.name), as: :json

    assert_response :success
    first_asset_id = json_response.first["id"]
    assert_equal asset1.id, first_asset_id
  end

  # ============================================
  # GET /api/v1/assets/:id (show)
  # ============================================
  test "GET /api/v1/assets/:id returns asset by id" do
    get api_v1_asset_url(@asset), as: :json

    assert_response :success
    assert_equal @asset.id, json_response["id"]
    assert_equal @asset.asset_type, json_response["asset_type"]
    assert json_response["download_url"].present?
  end

  test "GET /api/v1/assets/:id returns 404 for non-existent asset" do
    get api_v1_asset_url(999999), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/games/:game_id/assets (create)
  # ============================================
  test "POST /api/v1/games/:game_id/assets creates asset successfully" do
    post api_v1_game_assets_url(@game.name),
      params: {
        file: @test_file,
        asset_type: "COVER",
        order_index: 0
      },
      as: :multipart

    assert_response :created
    assert_equal "COVER", json_response["asset_type"]
    assert_equal @game.id, json_response["game_id"]
  end

  test "POST /api/v1/games/:game_id/assets creates asset without order_index" do
    post api_v1_game_assets_url(@game.name),
      params: {
        file: @test_file,
        asset_type: "SCREENSHOT"
      },
      as: :multipart

    assert_response :created
    assert_nil json_response["order_index"]
  end

  test "POST /api/v1/games/:game_id/assets returns 404 for non-existent game" do
    post api_v1_game_assets_url("Nonexistent"),
      params: {
        file: @test_file,
        asset_type: "COVER"
      },
      as: :multipart

    assert_response :not_found
  end

  test "POST /api/v1/games/:game_id/assets returns error for invalid asset type" do
    post api_v1_game_assets_url(@game.name),
      params: {
        file: @test_file,
        asset_type: "INVALID"
      },
      as: :multipart

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  # ============================================
  # PATCH /api/v1/assets/:id (update)
  # ============================================
  test "PATCH /api/v1/assets/:id updates order_index" do
    patch api_v1_asset_url(@asset),
      params: { order_index: 10 },
      as: :json

    assert_response :success
    assert_equal 10, json_response["order_index"]
  end

  test "PATCH /api/v1/assets/:id returns 404 for non-existent asset" do
    patch api_v1_asset_url(999999),
      params: { order_index: 10 },
      as: :json

    assert_response :not_found
  end

  # ============================================
  # DELETE /api/v1/assets/:id (destroy)
  # ============================================
  test "DELETE /api/v1/assets/:id disables asset" do
    delete api_v1_asset_url(@asset), as: :json

    assert_response :no_content
    assert @asset.reload.is_disabled
  end

  test "DELETE /api/v1/assets/:id returns 404 for non-existent asset" do
    delete api_v1_asset_url(999999), as: :json

    assert_response :not_found
  end

  # ============================================
  # GET /api/v1/assets/:id/download
  # ============================================
  test "GET /api/v1/assets/:id/download redirects to file URL" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: @test_file,
      filename: "test.png",
      content_type: "image/png"
    )
    asset = Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: blob.key,
      mime_type: "image/png",
      file_size: blob.byte_size
    )

    get download_api_v1_asset_url(asset)

    assert_response :redirect
  end

  test "GET /api/v1/assets/:id/download returns 404 for non-existent asset" do
    get download_api_v1_asset_url(999999)

    assert_response :not_found
  end

  # ============================================
  # Filtering by asset type
  # ============================================
  test "GET /api/v1/games/:game_id/assets?asset_type=COVER filters by type" do
    Asset.delete_all
    Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: "assets/cover.png",
      mime_type: "image/png",
      file_size: 1024
    )
    Asset.create!(
      game: @game,
      asset_type: "SCREENSHOT",
      storage_path: "assets/screenshot.png",
      mime_type: "image/png",
      file_size: 1024
    )

    get api_v1_game_assets_url(@game.name, asset_type: "COVER"), as: :json

    assert_response :success
    assert_equal 1, json_response.count
    assert_equal "COVER", json_response.first["asset_type"]
  end
end
