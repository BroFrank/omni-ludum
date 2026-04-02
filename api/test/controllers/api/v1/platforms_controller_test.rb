require "test_helper"

class Api::V1::PlatformsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Platform.delete_all
    @valid_platform_attrs = {
      name: "PC",
      slug: "pc"
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/platforms (index)
  # ============================================
  test "GET /api/v1/platforms returns list of active platforms" do
    platform1 = Platform.create!(@valid_platform_attrs)
    platform2 = Platform.create!(@valid_platform_attrs.merge(name: "PlayStation", slug: "playstation"))

    get api_v1_platforms_url, as: :json

    assert_response :success
    assert_equal 2, json_response.count
  end

  test "GET /api/v1/platforms does not return disabled platforms" do
    active_platform = Platform.create!(@valid_platform_attrs)
    disabled_platform = Platform.create!(@valid_platform_attrs.merge(name: "Disabled Platform", slug: "disabled", is_disabled: true))

    get api_v1_platforms_url, as: :json

    assert_response :success
    assert json_response.any? { |p| p["id"] == active_platform.id }
    assert_not json_response.any? { |p| p["id"] == disabled_platform.id }
  end

  test "GET /api/v1/platforms supports pagination" do
    25.times { |i| Platform.create!(@valid_platform_attrs.merge(name: "Platform #{i}", slug: "platform-#{i}")) }

    get api_v1_platforms_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  test "GET /api/v1/platforms returns empty array when no platforms" do
    get api_v1_platforms_url, as: :json

    assert_response :success
    assert_equal 0, json_response.count
  end

  # ============================================
  # GET /api/v1/platforms/:slug (show)
  # ============================================
  test "GET /api/v1/platforms/:slug returns platform by slug" do
    platform = Platform.create!(@valid_platform_attrs)

    get api_v1_platform_url(platform.slug), as: :json

    assert_response :success
    assert_equal platform.id, json_response["id"]
  end

  test "GET /api/v1/platforms/:slug returns 404 for non-existent platform" do
    get api_v1_platform_url("nonexistent"), as: :json

    assert_response :not_found
  end

  test "GET /api/v1/platforms/:slug returns 404 for disabled platform" do
    platform = Platform.create!(@valid_platform_attrs.merge(is_disabled: true))

    get api_v1_platform_url(platform.slug), as: :json

    assert_response :not_found
  end
end
