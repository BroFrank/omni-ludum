require "test_helper"

class JwtServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'Test123!@#'
    )
  end

  test 'encode should create a valid JWT token' do
    payload = { sub: @user.id, email: @user.email }
    token = JwtService.encode(payload)

    assert_not_nil token
    assert_kind_of String, token
  end

  test 'encode should include jti' do
    payload = { sub: @user.id, email: @user.email }
    token = JwtService.encode(payload)
    decoded = JWT.decode(token, JWT_SECRET_KEY, true, algorithm: 'HS256').first

    assert_not_nil decoded['jti']
  end

  test 'encode should include token_version when provided' do
    payload = { sub: @user.id, email: @user.email }
    token = JwtService.encode(payload, token_version: @user.token_version)
    decoded = JWT.decode(token, JWT_SECRET_KEY, true, algorithm: 'HS256').first

    assert_equal @user.token_version, decoded['token_version']
  end

  test 'decode should return payload from valid token' do
    payload = { sub: @user.id, email: @user.email, iat: Time.current.to_i }
    token = JwtService.encode(payload)
    decoded = JwtService.decode(token)

    assert_equal @user.id, decoded[:sub]
    assert_equal @user.email, decoded[:email]
  end

  test 'decode should raise error for expired token' do
    exp_payload = { sub: @user.id, exp: (Time.current - 1.hour).to_i }
    token = JWT.encode(exp_payload, JWT_SECRET_KEY, 'HS256')

    assert_raises { JwtService.decode(token) }
  end

  test 'decode should raise error for invalid token' do
    assert_raises { JwtService.decode('invalid_token') }
  end

  test 'decode should raise error when token is blacklisted' do
    jti = SecureRandom.uuid
    payload = { sub: @user.id, email: @user.email, jti: jti, exp: (Time.current + 1.hour).to_i, iat: Time.current.to_i }
    token = JWT.encode(payload, JWT_SECRET_KEY, 'HS256')

    AccessTokenBlacklist.add(jti, Time.current + 1.hour, reason: 'logout', user_id: @user.id)

    assert_raises { JwtService.decode(token) }
  end

  test 'decode should raise error for token version mismatch' do
    payload = { sub: @user.id, email: @user.email, token_version: 1 }
    token = JwtService.encode(payload)

    assert_raises { JwtService.decode(token, expected_token_version: 2) }
  end

  test 'decode should succeed for matching token version' do
    payload = { sub: @user.id, email: @user.email, token_version: 1 }
    token = JwtService.encode(payload)

    decoded = JwtService.decode(token, expected_token_version: 1)
    assert_equal 1, decoded[:token_version]
  end

  test 'verify should return true for valid token' do
    payload = { sub: @user.id, email: @user.email, iat: Time.current.to_i }
    token = JwtService.encode(payload)

    assert JwtService.verify(token)
  end

  test 'verify should return false for invalid token' do
    assert_not JwtService.verify('invalid_token')
  end

  test 'encoded token should have correct expiration' do
    payload = { sub: @user.id, email: @user.email }
    token = JwtService.encode(payload)
    decoded = JWT.decode(token, JWT_SECRET_KEY, true, algorithm: 'HS256').first

    expected_exp = (Time.current + JWT_ACCESS_TOKEN_EXPIRATION).to_i
    assert_in_delta expected_exp, decoded['exp'], 2
  end
end
