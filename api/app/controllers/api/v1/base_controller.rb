module Api
  module V1
    class BaseController < ApplicationController
      private

      def user_not_found
        render json: { error: "User not found" }, status: :not_found
      end

      def game_not_found
        render json: { error: "Game not found" }, status: :not_found
      end

      def asset_not_found
        render json: { error: "Asset not found" }, status: :not_found
      end

      def current_user
        @current_user ||= begin
          token = request.headers['Authorization']&.split(' ')&.last
          return nil unless token

          payload = JwtService.decode(token)
          User.find_by(id: payload[:sub])
        rescue StandardError
          nil
        end
      end

      def authenticated?
        current_user.present?
      end

      def require_authentication!
        return true if authenticated?

        render json: { error: 'Authentication required' }, status: :unauthorized
        false
      end
    end
  end
end
