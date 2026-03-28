require "test_helper"

class Api::V1::GenreTextsControllerTest < ActionDispatch::IntegrationTest
  setup do
    GenreText.delete_all
    @genre = Genre.create!(name: "RPG")
    @valid_attrs = {
      genre_id: @genre.id,
      lang_code: "en",
      description: "Test description"
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/genre_texts (index)
  # ============================================
  test "GET /api/v1/genre_texts returns list of genre texts" do
    GenreText.create!(@valid_attrs)
    GenreText.create!(@valid_attrs.merge(lang_code: "ru", description: "Русское описание"))

    get api_v1_genre_texts_url, as: :json

    assert_response :success
    assert_equal 2, json_response.count
  end

  test "GET /api/v1/genre_texts supports pagination" do
    25.times do |i|
      genre = Genre.create!(name: "Genre #{i}")
      GenreText.create!(genre: genre, lang_code: "en", description: "Desc #{i}")
    end

    get api_v1_genre_texts_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  # ============================================
  # GET /api/v1/genres/:slug/genre_texts (index)
  # ============================================
  test "GET /api/v1/genres/:slug/genre_texts returns texts for specific genre" do
    genre2 = Genre.create!(name: "Action")
    gt1 = GenreText.create!(@valid_attrs)
    gt2 = GenreText.create!(@valid_attrs.merge(genre: genre2, lang_code: "ru"))

    get api_v1_genre_genre_texts_url(@genre.slug), as: :json

    assert_response :success
    assert_equal 1, json_response.count
    assert_equal gt1.id, json_response.first["id"]
  end

  test "GET /api/v1/genres/:slug/genre_texts returns 404 for non-existent genre" do
    get api_v1_genre_genre_texts_url("nonexistent"), as: :json

    assert_response :not_found
  end

  # ============================================
  # GET /api/v1/genre_texts/:id (show)
  # ============================================
  test "GET /api/v1/genre_texts/:id returns genre text by id" do
    gt = GenreText.create!(@valid_attrs)

    get api_v1_genre_text_url(gt.id), as: :json

    assert_response :success
    assert_equal gt.id, json_response["id"]
  end

  test "GET /api/v1/genre_texts/:id returns 404 for non-existent text" do
    get api_v1_genre_text_url(999999), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/genre_texts (create)
  # ============================================
  test "POST /api/v1/genre_texts creates genre text successfully" do
    post api_v1_genre_texts_url, params: { genre_text: @valid_attrs }, as: :json

    assert_response :created
    assert_equal "Test description", json_response["description"]
  end

  test "POST /api/v1/genre_texts normalizes lang_code to lowercase" do
    post api_v1_genre_texts_url, params: {
      genre_text: @valid_attrs.merge(lang_code: "EN")
    }, as: :json

    assert_response :created
    assert_equal "en", json_response["lang_code"]
  end

  test "POST /api/v1/genre_texts returns validation errors for invalid lang_code" do
    post api_v1_genre_texts_url, params: {
      genre_text: @valid_attrs.merge(lang_code: "invalid")
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/genre_texts returns validation errors for missing genre_id" do
    post api_v1_genre_texts_url, params: {
      genre_text: { lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/genre_texts returns validation errors for non-existent genre" do
    post api_v1_genre_texts_url, params: {
      genre_text: { genre_id: 999999, lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :unprocessable_entity
    assert_includes json_response["errors"].join, "Genre must exist"
  end

  # ============================================
  # POST /api/v1/genres/:slug/genre_texts (create)
  # ============================================
  test "POST /api/v1/genres/:slug/genre_texts creates text for genre" do
    post api_v1_genre_genre_texts_url(@genre.slug), params: {
      genre_text: { genre_id: @genre.id, lang_code: "en", description: "Test description" }
    }, as: :json

    assert_response :created
    assert_equal "Test description", json_response["description"]
    assert_equal @genre.id, json_response["genre_id"]
  end

  test "POST /api/v1/genres/:slug/genre_texts returns 404 for non-existent genre" do
    post api_v1_genre_genre_texts_url("nonexistent"), params: {
      genre_text: { lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :not_found
  end

  # ============================================
  # PATCH /api/v1/genre_texts/:id (update)
  # ============================================
  test "PATCH /api/v1/genre_texts/:id updates genre text successfully" do
    gt = GenreText.create!(@valid_attrs)

    patch api_v1_genre_text_url(gt.id), params: {
      genre_text: { description: "Updated description" }
    }, as: :json

    assert_response :success
    assert_equal "Updated description", json_response["description"]
  end

  test "PATCH /api/v1/genre_texts/:id returns 404 for non-existent text" do
    patch api_v1_genre_text_url(999999), params: {
      genre_text: { description: "Updated" }
    }, as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/genre_texts/:id returns validation errors" do
    gt = GenreText.create!(@valid_attrs)

    patch api_v1_genre_text_url(gt.id), params: {
      genre_text: { lang_code: "invalid" }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  # ============================================
  # DELETE /api/v1/genre_texts/:id (destroy)
  # ============================================
  test "DELETE /api/v1/genre_texts/:id destroys genre text" do
    gt = GenreText.create!(@valid_attrs)

    delete api_v1_genre_text_url(gt.id), as: :json

    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      GenreText.find(gt.id)
    end
  end

  test "DELETE /api/v1/genre_texts/:id returns 404 for non-existent text" do
    delete api_v1_genre_text_url(999999), as: :json

    assert_response :not_found
  end
end
