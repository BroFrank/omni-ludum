require 'securerandom'

JWT_SECRET_KEY = Rails.application.credentials.jwt_secret_key || SecureRandom.alphanumeric(64)
JWT_ACCESS_TOKEN_EXPIRATION = (Rails.application.credentials.jwt_access_token_expiration || 15).minutes
JWT_REFRESH_TOKEN_EXPIRATION = (Rails.application.credentials.jwt_refresh_token_expiration || 30).days
