require "test_helper"

class Api::V1::GenresControllerTest < ActionDispatch::IntegrationTest
  setup do
    Genre.delete_all
    @valid_genre_attrs = {
      name: "RPG"
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/genres (index)
  # ============================================
  test "GET /api/v1/genres returns list of active genres" do
    genre1 = Genre.create!(@valid_genre_attrs)
    genre2 = Genre.create!(@valid_genre_attrs.merge(name: "Action"))

    get api_v1_genres_url, as: :json

    assert_response :success
    assert_equal 2, json_response.count
  end

  test "GET /api/v1/genres does not return disabled genres" do
    active_genre = Genre.create!(@valid_genre_attrs)
    disabled_genre = Genre.create!(@valid_genre_attrs.merge(name: "Disabled Genre", is_disabled: true))

    get api_v1_genres_url, as: :json

    assert_response :success
    assert json_response.any? { |g| g["id"] == active_genre.id }
    assert_not json_response.any? { |g| g["id"] == disabled_genre.id }
  end

  test "GET /api/v1/genres supports pagination" do
    25.times { |i| Genre.create!(@valid_genre_attrs.merge(name: "Genre #{i}")) }

    get api_v1_genres_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  test "GET /api/v1/genres returns empty array when no genres" do
    get api_v1_genres_url, as: :json

    assert_response :success
    assert_equal 0, json_response.count
  end

  # ============================================
  # GET /api/v1/genres/:slug (show)
  # ============================================
  test "GET /api/v1/genres/:slug returns genre by slug" do
    genre = Genre.create!(@valid_genre_attrs)

    get api_v1_genre_url(genre.slug), as: :json

    assert_response :success
    assert_equal genre.id, json_response["id"]
  end

  test "GET /api/v1/genres/:slug returns 404 for non-existent genre" do
    get api_v1_genre_url("nonexistent"), as: :json

    assert_response :not_found
  end

  test "GET /api/v1/genres/:slug returns 404 for disabled genre" do
    genre = Genre.create!(@valid_genre_attrs.merge(is_disabled: true))

    get api_v1_genre_url(genre.slug), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/genres (create)
  # ============================================
  test "POST /api/v1/genres creates genre successfully" do
    post api_v1_genres_url, params: { genre: @valid_genre_attrs }, as: :json

    assert_response :created
    assert_equal "RPG", json_response["name"]
  end

  test "POST /api/v1/genres auto-generates slug from name" do
    post api_v1_genres_url, params: {
      genre: { name: "Auto Slug Genre" }
    }, as: :json

    assert_response :created
    assert_equal "auto-slug-genre", json_response["slug"]
  end

  test "POST /api/v1/genres sets default value for is_disabled" do
    post api_v1_genres_url, params: { genre: @valid_genre_attrs }, as: :json

    assert_response :created
    assert_equal false, json_response["is_disabled"]
  end

  test "POST /api/v1/genres returns validation errors for missing name" do
    post api_v1_genres_url, params: {
      genre: { name: nil }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/genres accepts custom slug" do
    post api_v1_genres_url, params: {
      genre: { name: "Custom Slug", slug: "custom-slug" }
    }, as: :json

    assert_response :created
    assert_equal "custom-slug", json_response["slug"]
  end

  # ============================================
  # PATCH /api/v1/genres/:slug (update)
  # ============================================
  test "PATCH /api/v1/genres/:slug updates genre successfully" do
    genre = Genre.create!(@valid_genre_attrs)

    patch api_v1_genre_url(genre.slug), params: {
      genre: { name: "Updated Genre" }
    }, as: :json

    assert_response :success
    assert_equal "Updated Genre", json_response["name"]
  end

  test "PATCH /api/v1/genres/:slug returns 404 for non-existent genre" do
    patch api_v1_genre_url("nonexistent"), params: {
      genre: { name: "Updated Genre" }
    }, as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/genres/:slug returns validation errors" do
    genre = Genre.create!(@valid_genre_attrs)

    patch api_v1_genre_url(genre.slug), params: {
      genre: { name: nil }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any? { |e| e.include?("Name") }
  end

  test "PATCH /api/v1/genres/:slug can update slug" do
    genre = Genre.create!(@valid_genre_attrs)

    patch api_v1_genre_url(genre.slug), params: {
      genre: { slug: "custom-slug" }
    }, as: :json

    assert_response :success
    assert_equal "custom-slug", json_response["slug"]
  end

  # ============================================
  # PATCH /api/v1/genres/:slug/disable (disable)
  # ============================================
  test "PATCH /api/v1/genres/:slug/disable disables genre successfully" do
    genre = Genre.create!(@valid_genre_attrs)

    patch disable_api_v1_genre_url(genre.slug), as: :json

    assert_response :success
    assert json_response["is_disabled"]
  end

  test "PATCH /api/v1/genres/:slug/disable returns 404 for non-existent genre" do
    patch disable_api_v1_genre_url("nonexistent"), as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/genres/:slug/disable sets is_disabled to true" do
    genre = Genre.create!(@valid_genre_attrs)

    patch disable_api_v1_genre_url(genre.slug), as: :json

    assert_response :success
    genre.reload
    assert genre.is_disabled
  end

  test "PATCH /api/v1/genres/:slug/disable does not affect other genres" do
    genre1 = Genre.create!(@valid_genre_attrs)
    genre2 = Genre.create!(@valid_genre_attrs.merge(name: "Action"))

    patch disable_api_v1_genre_url(genre1.slug), as: :json

    assert_response :success
    assert genre1.reload.is_disabled
    assert_not genre2.reload.is_disabled
  end
end
