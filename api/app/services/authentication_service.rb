class AuthenticationService
  def self.authenticate(email, password)
    user = User.find_by(email: email&.downcase)
    return nil unless user&.authenticate(password)

    user
  end

  def self.generate_tokens(user)
    {
      access_token: generate_access_token(user),
      refresh_token: generate_refresh_token(user)
    }
  end

  def self.generate_access_token(user)
    payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      iat: Time.current.to_i
    }
    JwtService.encode(payload)
  end

  def self.generate_refresh_token(user)
    raw_token = SecureRandom.hex(32)
    token_digest = Digest::SHA256.hexdigest(raw_token)

    RefreshToken.create!(
      user: user,
      token_digest: token_digest,
      expires_at: Time.current + JWT_REFRESH_TOKEN_EXPIRATION
    )

    raw_token
  end

  def self.revoke_refresh_token(token)
    token_digest = Digest::SHA256.hexdigest(token)
    refresh_token = RefreshToken.find_by(token_digest: token_digest)
    return false unless refresh_token

    refresh_token.revoke!
    true
  end

  def self.revoke_all_user_tokens(user)
    RefreshToken.where(user: user).active.update_all(revoked_at: Time.current)
  end

  def self.cleanup_expired_tokens
    scope = RefreshToken.expired.or(RefreshToken.revoked)
    destroyed = scope.destroy_all
    Rails.logger.debug "Cleanup expired tokens: #{destroyed.length} records destroyed"
    destroyed.length
  end
end
