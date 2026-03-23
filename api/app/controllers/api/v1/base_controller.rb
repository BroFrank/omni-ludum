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
    end
  end
end
