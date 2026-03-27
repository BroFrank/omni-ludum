require "test_helper"

class Api::V1::PublisherTextsControllerTest < ActionDispatch::IntegrationTest
  setup do
    PublisherText.delete_all
    @publisher = Publisher.create!(name: "Test Publisher", type: PUBLISHER_TYPES::PUBLISHER)
    @valid_attrs = {
      publisher_id: @publisher.id,
      lang_code: "en",
      description: "Test description"
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/publisher_texts (index)
  # ============================================
  test "GET /api/v1/publisher_texts returns list of publisher texts" do
    PublisherText.create!(@valid_attrs)
    PublisherText.create!(@valid_attrs.merge(lang_code: "ru", description: "Русское описание"))

    get api_v1_publisher_texts_url, as: :json

    assert_response :success
    assert_equal 2, json_response.count
  end

  test "GET /api/v1/publisher_texts supports pagination" do
    25.times do |i|
      publisher = Publisher.create!(name: "Publisher #{i}", type: PUBLISHER_TYPES::PUBLISHER)
      PublisherText.create!(publisher: publisher, lang_code: "en", description: "Desc #{i}")
    end

    get api_v1_publisher_texts_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  # ============================================
  # GET /api/v1/publishers/:slug/publisher_texts (index)
  # ============================================
  test "GET /api/v1/publishers/:slug/publisher_texts returns texts for specific publisher" do
    publisher2 = Publisher.create!(name: "Another Publisher", type: PUBLISHER_TYPES::PUBLISHER)
    pt1 = PublisherText.create!(@valid_attrs)
    pt2 = PublisherText.create!(@valid_attrs.merge(publisher: publisher2, lang_code: "ru"))

    get api_v1_publisher_publisher_texts_url(@publisher.slug), as: :json

    assert_response :success
    assert_equal 1, json_response.count
    assert_equal pt1.id, json_response.first["id"]
  end

  test "GET /api/v1/publishers/:slug/publisher_texts returns 404 for non-existent publisher" do
    get api_v1_publisher_publisher_texts_url("nonexistent"), as: :json

    assert_response :not_found
  end

  # ============================================
  # GET /api/v1/publisher_texts/:id (show)
  # ============================================
  test "GET /api/v1/publisher_texts/:id returns publisher text by id" do
    pt = PublisherText.create!(@valid_attrs)

    get api_v1_publisher_text_url(pt.id), as: :json

    assert_response :success
    assert_equal pt.id, json_response["id"]
  end

  test "GET /api/v1/publisher_texts/:id returns 404 for non-existent text" do
    get api_v1_publisher_text_url(999999), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/publisher_texts (create)
  # ============================================
  test "POST /api/v1/publisher_texts creates publisher text successfully" do
    post api_v1_publisher_texts_url, params: { publisher_text: @valid_attrs }, as: :json

    assert_response :created
    assert_equal "Test description", json_response["description"]
  end

  test "POST /api/v1/publisher_texts normalizes lang_code to lowercase" do
    post api_v1_publisher_texts_url, params: {
      publisher_text: @valid_attrs.merge(lang_code: "EN")
    }, as: :json

    assert_response :created
    assert_equal "en", json_response["lang_code"]
  end

  test "POST /api/v1/publisher_texts returns validation errors for invalid lang_code" do
    post api_v1_publisher_texts_url, params: {
      publisher_text: @valid_attrs.merge(lang_code: "invalid")
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/publisher_texts returns validation errors for missing publisher_id" do
    post api_v1_publisher_texts_url, params: {
      publisher_text: { lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  test "POST /api/v1/publisher_texts returns 404 for non-existent publisher" do
    post api_v1_publisher_texts_url, params: {
      publisher_text: { publisher_id: 999999, lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :unprocessable_entity
    assert_includes json_response["errors"].join, "Publisher must exist"
  end

  # ============================================
  # POST /api/v1/publishers/:slug/publisher_texts (create)
  # ============================================
  test "POST /api/v1/publishers/:slug/publisher_texts creates text for publisher" do
    post api_v1_publisher_publisher_texts_url(@publisher.slug), params: {
      publisher_text: { publisher_id: @publisher.id, lang_code: "en", description: "Test description" }
    }, as: :json

    assert_response :created
    assert_equal "Test description", json_response["description"]
    assert_equal @publisher.id, json_response["publisher_id"]
  end

  test "POST /api/v1/publishers/:slug/publisher_texts returns 404 for non-existent publisher" do
    post api_v1_publisher_publisher_texts_url("nonexistent"), params: {
      publisher_text: { lang_code: "en", description: "Test" }
    }, as: :json

    assert_response :not_found
  end

  # ============================================
  # PATCH /api/v1/publisher_texts/:id (update)
  # ============================================
  test "PATCH /api/v1/publisher_texts/:id updates publisher text successfully" do
    pt = PublisherText.create!(@valid_attrs)

    patch api_v1_publisher_text_url(pt.id), params: {
      publisher_text: { description: "Updated description" }
    }, as: :json

    assert_response :success
    assert_equal "Updated description", json_response["description"]
  end

  test "PATCH /api/v1/publisher_texts/:id returns 404 for non-existent text" do
    patch api_v1_publisher_text_url(999999), params: {
      publisher_text: { description: "Updated" }
    }, as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/publisher_texts/:id returns validation errors" do
    pt = PublisherText.create!(@valid_attrs)

    patch api_v1_publisher_text_url(pt.id), params: {
      publisher_text: { lang_code: "invalid" }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].any?
  end

  # ============================================
  # DELETE /api/v1/publisher_texts/:id (destroy)
  # ============================================
  test "DELETE /api/v1/publisher_texts/:id deletes publisher text" do
    pt = PublisherText.create!(@valid_attrs)

    delete api_v1_publisher_text_url(pt.id), as: :json

    assert_response :no_content
    assert_raises ActiveRecord::RecordNotFound do
      PublisherText.find(pt.id)
    end
  end

  test "DELETE /api/v1/publisher_texts/:id returns 404 for non-existent text" do
    delete api_v1_publisher_text_url(999999), as: :json

    assert_response :not_found
  end
end
