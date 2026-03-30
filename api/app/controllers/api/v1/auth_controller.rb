module Api
  module V1
    class AuthController < BaseController
      def login
        user = AuthenticationService.authenticate(login_params[:email], login_params[:password])

        unless user
          return render_service_error('Invalid credentials', :unauthorized)
        end

        tokens = AuthenticationService.generate_tokens(user)
        set_refresh_token_cookie(tokens[:refresh_token])

        render json: {
          access_token: tokens[:access_token],
          expires_at: (Time.current + JWT_ACCESS_TOKEN_EXPIRATION).iso8601
        }
      end

      def refresh
        refresh_token = cookies[:refresh_token]

        unless refresh_token
          return render_service_error('Refresh token not found', :unauthorized)
        end

        tokens = RefreshTokenService.refresh_access_token(refresh_token)
        set_refresh_token_cookie(tokens[:refresh_token])

        render json: {
          access_token: tokens[:access_token],
          expires_at: (Time.current + JWT_ACCESS_TOKEN_EXPIRATION).iso8601
        }
      rescue StandardError => e
        render_service_error(e.message, :unauthorized)
      end

      def logout
        refresh_token = cookies[:refresh_token]

        if refresh_token
          token_digest = Digest::SHA256.hexdigest(refresh_token)
          refresh_token_record = RefreshToken.find_by(token_digest: token_digest)
          
          if refresh_token_record
            user = refresh_token_record.user
            add_access_token_to_blacklist(user)
          end
          
          AuthenticationService.revoke_refresh_token(refresh_token)
        end

        clear_refresh_token_cookie

        head :no_content
      end

      def logout_all
        return unless require_authentication!

        current_user.invalidate_all_tokens!

        head :no_content
      end

      private

      def add_access_token_to_blacklist(user)
        token = request.headers['Authorization']&.split(' ')&.last
        return unless token

        decoded = JWT.decode(token, JWT_SECRET_KEY, false)
        payload = decoded.first.with_indifferent_access

        AccessTokenBlacklist.add(
          payload[:jti],
          Time.at(payload['exp']),
          reason: 'logout',
          user_id: user.id
        )
      rescue StandardError
        Rails.logger.warn('Failed to add access token to blacklist')
      end

      def login_params
        params.permit(:email, :password)
      end

      def set_refresh_token_cookie(token)
        cookies[:refresh_token] = {
          value: token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          expires: Time.current + JWT_REFRESH_TOKEN_EXPIRATION,
          path: '/'
        }
      end

      def clear_refresh_token_cookie
        cookies.delete(:refresh_token, path: '/')
      end
    end
  end
end
