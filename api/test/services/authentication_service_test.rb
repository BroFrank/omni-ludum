require "test_helper"

class AuthenticationServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'Test123!@#'
    )
  end

  test 'authenticate should return user with valid credentials' do
    user = AuthenticationService.authenticate(@user.email, 'Test123!@#')
    assert_equal @user.id, user.id
  end

  test 'authenticate should return nil with invalid password' do
    user = AuthenticationService.authenticate(@user.email, 'wrongpassword')
    assert_nil user
  end

  test 'authenticate should return nil with invalid email' do
    user = AuthenticationService.authenticate('nonexistent@example.com', 'Test123!@#')
    assert_nil user
  end

  test 'authenticate should be case-insensitive for email' do
    user = AuthenticationService.authenticate(@user.email.upcase, 'Test123!@#')
    assert_equal @user.id, user.id
  end

  test 'generate_tokens should return access and refresh tokens' do
    tokens = AuthenticationService.generate_tokens(@user)
    assert_not_nil tokens[:access_token]
    assert_not_nil tokens[:refresh_token]
    assert_kind_of String, tokens[:access_token]
    assert_kind_of String, tokens[:refresh_token]
  end

  test 'generate_access_token should return valid JWT' do
    token = AuthenticationService.generate_access_token(@user)
    decoded = JwtService.decode(token)

    assert_equal @user.id, decoded[:sub]
    assert_equal @user.email, decoded[:email]
    assert_equal @user.role, decoded[:role]
  end

  test 'generate_refresh_token should create database record' do
    initial_count = RefreshToken.count
    token = AuthenticationService.generate_refresh_token(@user)

    assert_equal initial_count + 1, RefreshToken.count
    assert_kind_of String, token
    assert_not_nil RefreshToken.find_by(user: @user)
  end

  test 'revoke_refresh_token should revoke token by raw token' do
    raw_token = AuthenticationService.generate_refresh_token(@user)
    refresh_token = RefreshToken.find_by(user: @user)
    assert_not refresh_token.revoked?

    result = AuthenticationService.revoke_refresh_token(raw_token)
    assert result

    refresh_token.reload
    assert refresh_token.revoked?
  end

  test 'revoke_refresh_token should return false for non-existent token' do
    result = AuthenticationService.revoke_refresh_token('nonexistent_token')
    assert_not result
  end

  test 'revoke_all_user_tokens should revoke all active tokens for user' do
    # Create multiple tokens
    AuthenticationService.generate_refresh_token(@user)
    AuthenticationService.generate_refresh_token(@user)

    AuthenticationService.revoke_all_user_tokens(@user)

    assert RefreshToken.where(user: @user).all?(&:revoked?)
  end

  test 'cleanup_expired_tokens should remove revoked tokens' do
    # Create unique token for this test
    token = RefreshToken.create!(
      user: @user,
      token_digest: "cleanup_test_#{Time.current.to_i}",
      expires_at: Time.current + 30.days,
      revoked_at: Time.current
    )

    cleaned_count = AuthenticationService.cleanup_expired_tokens

    assert cleaned_count >= 1, "Expected to clean at least 1 token, got #{cleaned_count}"
    assert_not RefreshToken.exists?(id: token.id)
  end
end
