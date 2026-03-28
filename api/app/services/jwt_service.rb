class JwtService
  def self.encode(payload)
    exp_payload = payload.merge(exp: (Time.current + JWT_ACCESS_TOKEN_EXPIRATION).to_i)
    JWT.encode(exp_payload, JWT_SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, JWT_SECRET_KEY, true, algorithm: 'HS256')
    decoded.first.with_indifferent_access
  rescue JWT::ExpiredSignature
    raise 'Token expired'
  rescue JWT::DecodeError => e
    raise "Invalid token: #{e.message}"
  end

  def self.verify(token)
    decode(token)
    true
  rescue StandardError
    false
  end
end
