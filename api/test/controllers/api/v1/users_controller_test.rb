require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_user_attrs = {
      username: "testuser",
      email: "test@example.com",
      password: "Password1!",
      password_confirmation: "Password1!"
    }
  end

  private

  def json_response
    JSON.parse(response.body)
  end

  # ============================================
  # GET /api/v1/users (index)
  # ============================================
  test "GET /api/v1/users returns list of active users" do
    user1 = User.create!(@valid_user_attrs)
    user2 = User.create!(@valid_user_attrs.merge(username: "user2", email: "user2@example.com"))

    get api_v1_users_url, as: :json

    assert_response :success
    assert_equal 2, json_response.count
  end

  test "GET /api/v1/users does not return disabled users" do
    active_user = User.create!(@valid_user_attrs)
    disabled_user = User.create!(@valid_user_attrs.merge(username: "disabled", email: "disabled@example.com", is_disabled: true))

    get api_v1_users_url, as: :json

    assert_response :success
    assert json_response.any? { |u| u["id"] == active_user.id }
    assert_not json_response.any? { |u| u["id"] == disabled_user.id }
  end

  test "GET /api/v1/users supports pagination" do
    25.times { |i| User.create!(@valid_user_attrs.merge(username: "user#{i}", email: "user#{i}@example.com")) }

    get api_v1_users_url, as: :json

    assert_response :success
    assert_equal 20, json_response.count
  end

  test "GET /api/v1/users returns empty array when no users" do
    get api_v1_users_url, as: :json

    assert_response :success
    assert_equal 0, json_response.count
  end

  # ============================================
  # GET /api/v1/users/:id (show)
  # ============================================
  test "GET /api/v1/users/:id returns user by slug" do
    user = User.create!(@valid_user_attrs)

    get api_v1_user_url(user.slug), as: :json

    assert_response :success
    assert_equal user.id, json_response["id"]
  end

  test "GET /api/v1/users/:id returns 404 for non-existent user" do
    get api_v1_user_url("nonexistent"), as: :json

    assert_response :not_found
  end

  test "GET /api/v1/users/:id returns 404 for disabled user" do
    user = User.create!(@valid_user_attrs.merge(is_disabled: true))

    get api_v1_user_url(user.slug), as: :json

    assert_response :not_found
  end

  # ============================================
  # POST /api/v1/users (create)
  # ============================================
  test "POST /api/v1/users creates user successfully" do
    post api_v1_users_url, params: { user: @valid_user_attrs }, as: :json

    assert_response :created
    assert_equal "testuser", json_response["username"]
  end

  test "POST /api/v1/users generates slug automatically" do
    post api_v1_users_url, params: { user: @valid_user_attrs }, as: :json

    assert_response :created
    assert_equal "testuser", json_response["slug"]
  end

  test "POST /api/v1/users sets default role to REGULAR" do
    post api_v1_users_url, params: { user: @valid_user_attrs }, as: :json

    assert_response :created
    assert_equal USER_ROLES::REGULAR, json_response["role"]
  end

  test "POST /api/v1/users returns validation errors" do
    post api_v1_users_url, params: {
      user: {
        username: "ab",
        email: "invalid",
        password: "short"
      }
    }, as: :json

    assert_response :unprocessable_entity
    assert_includes json_response["errors"].join(", "), "Username"
    assert_includes json_response["errors"].join(", "), "Email"
    assert_includes json_response["errors"].join(", "), "Password"
  end

  test "POST /api/v1/users with special characters in username returns error" do
    post api_v1_users_url, params: {
      user: @valid_user_attrs.merge(username: "test@user")
    }, as: :json

    assert_response :unprocessable_entity
    assert_includes json_response["errors"].join(", "), "Username"
  end

  # ============================================
  # PATCH /api/v1/users/:id (update)
  # ============================================
  test "PATCH /api/v1/users/:id updates user successfully" do
    user = User.create!(@valid_user_attrs)

    patch api_v1_user_url(user.slug), params: {
      user: { username: "updateduser" }
    }, as: :json

    assert_response :success
    assert_equal "updateduser", json_response["username"]
  end

  test "PATCH /api/v1/users/:id returns 404 for non-existent user" do
    patch api_v1_user_url("nonexistent"), params: {
      user: { username: "updateduser" }
    }, as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/users/:id returns validation errors" do
    user = User.create!(@valid_user_attrs)

    patch api_v1_user_url(user.slug), params: {
      user: { username: "ab" }
    }, as: :json

    assert_response :unprocessable_entity
    assert_includes json_response["errors"].join(", "), "Username"
  end

  test "PATCH /api/v1/users/:id can update email" do
    user = User.create!(@valid_user_attrs)

    patch api_v1_user_url(user.slug), params: {
      user: { email: "newemail@example.com" }
    }, as: :json

    assert_response :success
    assert_equal "newemail@example.com", json_response["email"]
  end

  test "PATCH /api/v1/users/:id can update password" do
    user = User.create!(@valid_user_attrs)

    patch api_v1_user_url(user.slug), params: {
      user: {
        password: "NewPassword1!",
        password_confirmation: "NewPassword1!"
      }
    }, as: :json

    assert_response :success
    assert User.find_by_slug(user.slug).authenticate("NewPassword1!")
  end

  test "PATCH /api/v1/users/:id can update role" do
    user = User.create!(@valid_user_attrs)

    patch api_v1_user_url(user.slug), params: {
      user: { role: USER_ROLES::ADMIN }
    }, as: :json

    assert_response :success
    assert_equal USER_ROLES::ADMIN, json_response["role"]
  end

  # ============================================
  # PATCH /api/v1/users/:id/disable (disable)
  # ============================================
  test "PATCH /api/v1/users/:id/disable disables user successfully" do
    user = User.create!(@valid_user_attrs)

    patch disable_api_v1_user_url(user.slug), as: :json

    assert_response :success
    assert json_response["is_disabled"]
  end

  test "PATCH /api/v1/users/:id/disable returns 404 for non-existent user" do
    patch disable_api_v1_user_url("nonexistent"), as: :json

    assert_response :not_found
  end

  test "PATCH /api/v1/users/:id/disable sets is_disabled to true" do
    user = User.create!(@valid_user_attrs)

    patch disable_api_v1_user_url(user.slug), as: :json

    assert_response :success
    user.reload
    assert user.is_disabled
  end

  test "PATCH /api/v1/users/:id/disable does not affect other users" do
    user1 = User.create!(@valid_user_attrs)
    user2 = User.create!(@valid_user_attrs.merge(username: "user2", email: "user2@example.com"))

    patch disable_api_v1_user_url(user1.slug), as: :json

    assert_response :success
    assert user1.reload.is_disabled
    assert_not user2.reload.is_disabled
  end
end
