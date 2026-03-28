require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'Test123!@#'
    )
  end

  test 'POST /login should return access token with valid credentials' do
    post api_v1_auth_login_path, params: {
      email: @user.email,
      password: 'Test123!@#'
    }

    assert_response :success
    assert_not_nil response.parsed_body['access_token']
    assert_not_nil response.parsed_body['expires_at']
  end

  test 'POST /login should return 401 with invalid credentials' do
    post api_v1_auth_login_path, params: {
      email: @user.email,
      password: 'wrongpassword'
    }

    assert_response :unauthorized
    assert_equal 'Invalid credentials', response.parsed_body['error']
  end

  test 'POST /login should return 401 with non-existent email' do
    post api_v1_auth_login_path, params: {
      email: 'nonexistent@example.com',
      password: 'Test123!@#'
    }

    assert_response :unauthorized
  end

  test 'POST /refresh should return new access token with valid refresh token' do
    refresh_token = AuthenticationService.generate_refresh_token(@user)

    post api_v1_auth_refresh_path,
      headers: { 'HTTP_COOKIE' => "refresh_token=#{refresh_token}" }

    assert_response :success
    assert_not_nil response.parsed_body['access_token']
    assert_not_nil response.parsed_body['expires_at']
  end

  test 'POST /refresh should return 401 without refresh token' do
    post api_v1_auth_refresh_path

    assert_response :unauthorized
    assert_equal 'Refresh token not found', response.parsed_body['error']
  end

  test 'POST /refresh should return 401 with invalid refresh token' do
    post api_v1_auth_refresh_path,
      headers: { 'HTTP_COOKIE' => 'refresh_token=invalid_token' }

    assert_response :unauthorized
  end

  test 'DELETE /logout should return no content' do
    delete api_v1_auth_logout_path

    assert_response :no_content
  end

  test 'DELETE /logout_all should require authentication' do
    delete api_v1_auth_logout_all_path

    assert_response :unauthorized
  end

  test 'DELETE /logout_all should revoke all user tokens when authenticated' do
    # Create multiple tokens
    AuthenticationService.generate_refresh_token(@user)
    AuthenticationService.generate_refresh_token(@user)

    # Get access token
    access_token = AuthenticationService.generate_access_token(@user)

    delete api_v1_auth_logout_all_path,
      headers: { 'Authorization' => "Bearer #{access_token}" }

    assert_response :no_content
    assert RefreshToken.where(user: @user).all?(&:revoked?)
  end
end
