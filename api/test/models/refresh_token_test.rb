require "test_helper"

class RefreshTokenTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'Test123!@#'
    )
  end

  test 'should be valid with valid attributes' do
    refresh_token = RefreshToken.new(
      user: @user,
      token_digest: 'abc123',
      expires_at: Time.current + 30.days
    )
    assert refresh_token.valid?
  end

  test 'should require user_id' do
    refresh_token = RefreshToken.new(
      token_digest: 'abc123',
      expires_at: Time.current + 30.days
    )
    assert_not refresh_token.valid?
    assert_includes refresh_token.errors[:user], "must exist"
  end

  test 'should require token_digest' do
    refresh_token = RefreshToken.new(
      user: @user,
      expires_at: Time.current + 30.days
    )
    assert_not refresh_token.valid?
    assert_includes refresh_token.errors[:token_digest], "can't be blank"
  end

  test 'should require expires_at' do
    refresh_token = RefreshToken.new(
      user: @user,
      token_digest: 'abc123'
    )
    assert_not refresh_token.valid?
    assert_includes refresh_token.errors[:expires_at], "can't be blank"
  end

  test 'active scope should return non-revoked and non-expired tokens' do
    valid_token = RefreshToken.create!(
      user: @user,
      token_digest: 'valid_digest',
      expires_at: Time.current + 30.days
    )
    expired_token = RefreshToken.create!(
      user: @user,
      token_digest: 'expired_digest',
      expires_at: Time.current - 1.day
    )
    revoked_token = RefreshToken.create!(
      user: @user,
      token_digest: 'revoked_digest',
      expires_at: Time.current + 30.days,
      revoked_at: Time.current
    )

    assert_includes RefreshToken.active, valid_token
    assert_not_includes RefreshToken.active, expired_token
    assert_not_includes RefreshToken.active, revoked_token
  end

  test 'expired scope should return expired tokens' do
    expired_token = RefreshToken.create!(
      user: @user,
      token_digest: 'expired_digest',
      expires_at: Time.current - 1.day
    )
    valid_token = RefreshToken.create!(
      user: @user,
      token_digest: 'valid_digest',
      expires_at: Time.current + 30.days
    )

    assert_includes RefreshToken.expired, expired_token
    assert_not_includes RefreshToken.expired, valid_token
  end

  test 'revoked scope should return revoked tokens' do
    revoked_token = RefreshToken.create!(
      user: @user,
      token_digest: 'revoked_digest',
      expires_at: Time.current + 30.days,
      revoked_at: Time.current
    )
    valid_token = RefreshToken.create!(
      user: @user,
      token_digest: 'valid_digest',
      expires_at: Time.current + 30.days
    )

    assert_includes RefreshToken.revoked, revoked_token
    assert_not_includes RefreshToken.revoked, valid_token
  end

  test 'active? should return false for revoked token' do
    refresh_token = RefreshToken.create!(
      user: @user,
      token_digest: 'test_digest',
      expires_at: Time.current + 30.days
    )
    assert refresh_token.active?

    refresh_token.revoke!
    assert_not refresh_token.active?
  end

  test 'active? should return false for expired token' do
    refresh_token = RefreshToken.create!(
      user: @user,
      token_digest: 'test_digest',
      expires_at: Time.current - 1.day
    )
    assert_not refresh_token.active?
  end

  test 'revoke! should set revoked_at' do
    refresh_token = RefreshToken.create!(
      user: @user,
      token_digest: 'test_digest',
      expires_at: Time.current + 30.days
    )
    assert_nil refresh_token.revoked_at

    refresh_token.revoke!
    assert_not_nil refresh_token.revoked_at
  end

  test 'revoked? should return true if revoked' do
    refresh_token = RefreshToken.create!(
      user: @user,
      token_digest: 'test_digest',
      expires_at: Time.current + 30.days
    )
    assert_not refresh_token.revoked?

    refresh_token.revoke!
    assert refresh_token.revoked?
  end

  test 'expired? should return true if expired' do
    valid_token = RefreshToken.create!(
      user: @user,
      token_digest: 'valid_digest',
      expires_at: Time.current + 30.days
    )
    assert_not valid_token.expired?

    expired_token = RefreshToken.create!(
      user: @user,
      token_digest: 'expired_digest',
      expires_at: Time.current - 1.day
    )
    assert expired_token.expired?
  end
end
