class RefreshTokenService
  def self.refresh_access_token(refresh_token)
    raw_token = refresh_token
    token_digest = Digest::SHA256.hexdigest(raw_token)

    refresh_token_record = RefreshToken
      .includes(:user)
      .find_by(token_digest: token_digest)

    raise 'Invalid refresh token' unless refresh_token_record
    raise 'Refresh token revoked' if refresh_token_record.revoked?
    raise 'Refresh token expired' if refresh_token_record.expired?

    user = refresh_token_record.user

    refresh_token_record.revoke!

    {
      access_token: AuthenticationService.generate_access_token(user),
      refresh_token: AuthenticationService.generate_refresh_token(user)
    }
  end

  def self.validate_refresh_token(token)
    token_digest = Digest::SHA256.hexdigest(token)
    refresh_token = RefreshToken.find_by(token_digest: token_digest)
    return false unless refresh_token

    refresh_token.active?
  end
end
