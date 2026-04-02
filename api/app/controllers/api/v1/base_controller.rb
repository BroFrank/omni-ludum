module Api
  module V1
    class BaseController < ApplicationController
      DEFAULT_PER_PAGE = 20

      rescue_from ActiveRecord::RecordNotFound do |e|
        render_not_found(e.model.class.name.demodulize.humanize)
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: "Missing required parameter: #{e.param}" }, status: :bad_request
      end

      rescue_from StandardError do |e|
        Rails.logger.error(e)
        render json: { error: "Internal server error" }, status: :internal_server_error
      end

      private

      def user_not_found
        render_not_found("User")
      end

      def game_not_found
        render_not_found("Game")
      end

      def asset_not_found
        render_not_found("Asset")
      end

      def publisher_not_found
        render_not_found("Publisher")
      end

      def genre_not_found
        render_not_found("Genre")
      end

      def platform_not_found
        render_not_found("Platform")
      end

      def render_not_found(resource_name = "Resource")
        render json: { error: "#{resource_name} not found" }, status: :not_found
      end

      def render_validation_errors(model, status: :unprocessable_entity)
        render json: { errors: model.errors.full_messages }, status: status
      end

      def render_service_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end

      def current_user
        @current_user ||= begin
          token = request.headers["Authorization"]&.split(" ")&.last
          return nil unless token

          payload = JwtService.decode(token)
          user = User.find_by(id: payload[:sub])

          if user && payload[:token_version] && payload[:token_version] != user.token_version
            raise "Token version mismatch - tokens have been invalidated"
          end

          user
        rescue StandardError
          nil
        end
      end

      def authenticated?
        current_user.present?
      end

      def require_authentication!
        return true if authenticated?

        render json: { error: "Authentication required" }, status: :unauthorized
        false
      end
    end
  end
end
