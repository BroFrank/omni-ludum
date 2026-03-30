class JwtService
  def self.encode(payload, token_version: nil)
    payload = payload.merge(
      jti: SecureRandom.uuid,
      iat: Time.current.to_i,
      exp: (Time.current + JWT_ACCESS_TOKEN_EXPIRATION).to_i
    )
    payload[:token_version] = token_version if token_version
    JWT.encode(payload, JWT_SECRET_KEY, 'HS256')
  end

  def self.decode(token, expected_token_version: nil)
    decoded = JWT.decode(token, JWT_SECRET_KEY, true, algorithm: 'HS256')
    payload = decoded.first.with_indifferent_access

    if AccessTokenBlacklist.revoked?(payload[:jti])
      raise 'Token has been revoked'
    end

    if expected_token_version && payload[:token_version] != expected_token_version
      raise 'Token version mismatch - tokens have been invalidated'
    end

    payload
  rescue JWT::ExpiredSignature
    raise 'Token expired'
  rescue JWT::DecodeError => e
    raise "Invalid token: #{e.message}"
  end

  def self.verify(token, expected_token_version: nil)
    decode(token, expected_token_version: expected_token_version)
    true
  rescue StandardError
    false
  end
end
