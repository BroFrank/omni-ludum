require "test_helper"

class Api::V1::PublishersControllerTest < ActionDispatch::IntegrationTest
  setup do
    Publisher.delete_all
    @valid_publisher_attrs = {
      name: "Test Publisher",
      type: PUBLISHER_TYPES::PUBLISHER
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/publishers (index)
  # ============================================
  test "GET /api/v1/publishers returns list of active publishers" do
    publisher1 = Publisher.create!(@valid_publisher_attrs)
    publisher2 = Publisher.create!(@valid_publisher_attrs.merge(name: "Publisher 2"))

    get api_v1_publishers_url, as: :json

    assert_response :success
    assert_equal 2, json_response.count
  end

  test "GET /api/v1/publishers does not return disabled publishers" do
    active_publisher = Publisher.create!(@valid_publisher_attrs)
    disabled_publisher = Publisher.create!(@valid_publisher_attrs.merge(name: "Disabled Publisher", is_disabled: true))

    get api_v1_publishers_url, as: :json

    assert_response :success
    assert json_response.any? { |p| p["id"] == active_publisher.id }
    assert_not json_response.any? { |p| p["id"] == disabled_publisher.id }
  end

  test "GET /api/v1/publishers supports pagination" do
    25.times { |i| Publisher.create!(@valid_publisher_attrs.merge(name: "Publisher #{i}")) }

    get api_v1_publishers_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  test "GET /api/v1/publishers returns empty array when no publishers" do
    get api_v1_publishers_url, as: :json

    assert_response :success
    assert_equal 0, json_response.count
  end

  # ============================================
  # GET /api/v1/publishers/:id (show)
  # ============================================
  test "GET /api/v1/publishers/:id returns publisher by slug" do
    publisher = Publisher.create!(@valid_publisher_attrs)

    get api_v1_publisher_url(publisher.slug), as: :json

    assert_response :success
    assert_equal publisher.id, json_response["id"]
  end

  test "GET /api/v1/publishers/:id returns 404 for non-existent publisher" do
    get api_v1_publisher_url("nonexistent"), as: :json

    assert_response :not_found
  end

  test "GET /api/v1/publishers/:id returns 404 for disabled publisher" do
    publisher = Publisher.create!(@valid_publisher_attrs.merge(is_disabled: true))

    get api_v1_publisher_url(publisher.slug), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/publishers (create)
  # ============================================
  test "POST /api/v1/publishers creates publisher successfully" do
    post api_v1_publishers_url, params: { publisher: @valid_publisher_attrs }, as: :json

    assert_response :created
    assert_equal "Test Publisher", json_response["name"]
  end

  test "POST /api/v1/publishers auto-generates slug from name" do
    post api_v1_publishers_url, params: {
      publisher: { name: "Auto Slug Publisher", type: PUBLISHER_TYPES::PUBLISHER }
    }, as: :json

    assert_response :created
    assert_equal "auto-slug-publisher", json_response["slug"]
  end

  test "POST /api/v1/publishers sets default value for is_disabled" do
    post api_v1_publishers_url, params: { publisher: @valid_publisher_attrs }, as: :json

    assert_response :created
    assert_equal false, json_response["is_disabled"]
  end

  test "POST /api/v1/publishers normalizes type to uppercase" do
    post api_v1_publishers_url, params: {
      publisher: { name: "Test", type: "developer" }
    }, as: :json

    assert_response :created
    assert_equal "DEVELOPER", json_response["type"]
  end

  test "POST /api/v1/publishers returns validation errors for missing name" do
    post api_v1_publishers_url, params: {
      publisher: { name: nil, type: PUBLISHER_TYPES::PUBLISHER }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/publishers returns validation errors for missing type" do
    post api_v1_publishers_url, params: {
      publisher: { name: "Test", type: nil }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/publishers returns validation errors for invalid type" do
    post api_v1_publishers_url, params: {
      publisher: { name: "Test", type: "INVALID" }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/publishers creates developer type" do
    post api_v1_publishers_url, params: {
      publisher: { name: "Dev Studio", type: PUBLISHER_TYPES::DEVELOPER }
    }, as: :json

    assert_response :created
    assert_equal "DEVELOPER", json_response["type"]
  end

  test "POST /api/v1/publishers creates person type" do
    post api_v1_publishers_url, params: {
      publisher: { name: "John Doe", type: PUBLISHER_TYPES::PERSON }
    }, as: :json

    assert_response :created
    assert_equal "PERSON", json_response["type"]
  end

  # ============================================
  # PATCH /api/v1/publishers/:id (update)
  # ============================================
  test "PATCH /api/v1/publishers/:id updates publisher successfully" do
    publisher = Publisher.create!(@valid_publisher_attrs)

    patch api_v1_publisher_url(publisher.slug), params: {
      publisher: { name: "Updated Publisher" }
    }, as: :json

    assert_response :success
    assert_equal "Updated Publisher", json_response["name"]
  end

  test "PATCH /api/v1/publishers/:id returns 404 for non-existent publisher" do
    patch api_v1_publisher_url("nonexistent"), params: {
      publisher: { name: "Updated Publisher" }
    }, as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/publishers/:id returns validation errors" do
    publisher = Publisher.create!(@valid_publisher_attrs)

    patch api_v1_publisher_url(publisher.slug), params: {
      publisher: { name: nil }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any? { |e| e.include?("Name") }
  end

  test "PATCH /api/v1/publishers/:id can update type" do
    publisher = Publisher.create!(@valid_publisher_attrs)

    patch api_v1_publisher_url(publisher.slug), params: {
      publisher: { type: PUBLISHER_TYPES::DEVELOPER }
    }, as: :json

    assert_response :success
    assert_equal "DEVELOPER", json_response["type"]
  end

  test "PATCH /api/v1/publishers/:id can update slug" do
    publisher = Publisher.create!(@valid_publisher_attrs)

    patch api_v1_publisher_url(publisher.slug), params: {
      publisher: { slug: "custom-slug" }
    }, as: :json

    assert_response :success
    assert_equal "custom-slug", json_response["slug"]
  end

  # ============================================
  # PATCH /api/v1/publishers/:id/disable (disable)
  # ============================================
  test "PATCH /api/v1/publishers/:id/disable disables publisher successfully" do
    publisher = Publisher.create!(@valid_publisher_attrs)

    patch disable_api_v1_publisher_url(publisher.slug), as: :json

    assert_response :success
    assert json_response["is_disabled"]
  end

  test "PATCH /api/v1/publishers/:id/disable returns 404 for non-existent publisher" do
    patch disable_api_v1_publisher_url("nonexistent"), as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/publishers/:id/disable sets is_disabled to true" do
    publisher = Publisher.create!(@valid_publisher_attrs)

    patch disable_api_v1_publisher_url(publisher.slug), as: :json

    assert_response :success
    publisher.reload
    assert publisher.is_disabled
  end

  test "PATCH /api/v1/publishers/:id/disable nullifies games publisher_id" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    game = Game.create!(name: "Test Game", release_year: 2020, publisher: publisher)

    patch disable_api_v1_publisher_url(publisher.slug), as: :json

    assert_response :success
    game.reload
    assert_nil game.publisher_id
  end

  test "PATCH /api/v1/publishers/:id/disable does not affect other publishers" do
    publisher1 = Publisher.create!(@valid_publisher_attrs)
    publisher2 = Publisher.create!(@valid_publisher_attrs.merge(name: "Publisher 2"))

    patch disable_api_v1_publisher_url(publisher1.slug), as: :json

    assert_response :success
    assert publisher1.reload.is_disabled
    assert_not publisher2.reload.is_disabled
  end
end
