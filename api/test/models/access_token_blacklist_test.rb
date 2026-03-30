require "test_helper"

class AccessTokenBlacklistTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'Test123!@#'
    )
    @jti = SecureRandom.uuid
    @expires_at = Time.current + 1.hour
  end

  test 'should create blacklist entry' do
    result = AccessTokenBlacklist.add(@jti, @expires_at)

    assert result
    assert AccessTokenBlacklist.exists?(jti: @jti)
  end

  test 'should handle duplicate jti gracefully' do
    AccessTokenBlacklist.add(@jti, @expires_at)
    result = AccessTokenBlacklist.add(@jti, @expires_at)

    assert_equal false, result
  end

  test 'revoked? should return true for active blacklist' do
    AccessTokenBlacklist.add(@jti, @expires_at)

    assert AccessTokenBlacklist.revoked?(@jti)
  end

  test 'revoked? should return false for non-blacklisted jti' do
    assert_not AccessTokenBlacklist.revoked?(SecureRandom.uuid)
  end

  test 'revoked? should return false for expired blacklist' do
    AccessTokenBlacklist.add(@jti, Time.current - 1.hour)

    assert_not AccessTokenBlacklist.revoked?(@jti)
  end

  test 'should cleanup old expired entries' do
    old_jti = SecureRandom.uuid
    old_expires_at = Time.current - 2.days
    old_created_at = 10.days.ago

    AccessTokenBlacklist.create!(
      jti: old_jti,
      expires_at: old_expires_at,
      created_at: old_created_at
    )

    recent_jti = SecureRandom.uuid
    recent_expires_at = Time.current - 1.hour
    recent_created_at = 1.day.ago

    AccessTokenBlacklist.create!(
      jti: recent_jti,
      expires_at: recent_expires_at,
      created_at: recent_created_at
    )

    destroyed = AccessTokenBlacklist.cleanup_old(days_old: 7)

    assert_equal 1, destroyed.length
    assert_not AccessTokenBlacklist.exists?(jti: old_jti)
    assert AccessTokenBlacklist.exists?(jti: recent_jti)
  end

  test 'should associate with user' do
    AccessTokenBlacklist.create!(
      jti: @jti,
      expires_at: @expires_at,
      user: @user,
      reason: 'logout'
    )

    blacklist = AccessTokenBlacklist.find_by(jti: @jti)
    assert_equal @user.id, blacklist.user_id
    assert_equal 'logout', blacklist.reason
  end
end
