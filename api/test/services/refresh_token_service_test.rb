require "test_helper"

class RefreshTokenServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'Test123!@#'
    )
  end

  test 'refresh_access_token should return new tokens for valid refresh token' do
    old_refresh_token = AuthenticationService.generate_refresh_token(@user)
    
    tokens = RefreshTokenService.refresh_access_token(old_refresh_token)
    
    assert_not_nil tokens[:access_token]
    assert_not_nil tokens[:refresh_token]
    assert_kind_of String, tokens[:access_token]
    assert_kind_of String, tokens[:refresh_token]
  end

  test 'refresh_access_token should revoke old refresh token' do
    old_refresh_token = AuthenticationService.generate_refresh_token(@user)
    refresh_token_record = RefreshToken.find_by(user: @user)
    
    RefreshTokenService.refresh_access_token(old_refresh_token)
    
    refresh_token_record.reload
    assert refresh_token_record.revoked?
  end

  test 'refresh_access_token should raise error for invalid token' do
    assert_raises { RefreshTokenService.refresh_access_token('invalid_token') }
  end

  test 'refresh_access_token should raise error for revoked token' do
    old_refresh_token = AuthenticationService.generate_refresh_token(@user)
    RefreshToken.find_by(user: @user).revoke!
    
    assert_raises { RefreshTokenService.refresh_access_token(old_refresh_token) }
  end

  test 'refresh_access_token should raise error for expired token' do
    refresh_token = RefreshToken.create!(
      user: @user,
      token_digest: Digest::SHA256.hexdigest('test_token'),
      expires_at: Time.current - 1.day
    )
    
    assert_raises { RefreshTokenService.refresh_access_token('test_token') }
  end

  test 'validate_refresh_token should return false for revoked token' do
    raw_token = AuthenticationService.generate_refresh_token(@user)
    RefreshToken.find_by(user: @user).revoke!

    assert_not RefreshTokenService.validate_refresh_token(raw_token)
  end

  test 'validate_refresh_token should return true for valid token' do
    raw_token = AuthenticationService.generate_refresh_token(@user)

    assert RefreshTokenService.validate_refresh_token(raw_token)
  end

  test 'validate_refresh_token should return false for invalid token' do
    assert_not RefreshTokenService.validate_refresh_token('invalid_token')
  end

  test 'validate_refresh_token should return false for expired token' do
    RefreshToken.create!(
      user: @user,
      token_digest: Digest::SHA256.hexdigest('expired_token'),
      expires_at: Time.current - 1.day
    )
    
    assert_not RefreshTokenService.validate_refresh_token('expired_token')
  end
end
