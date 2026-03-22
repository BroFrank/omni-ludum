module Api
  module V1
    class BaseController < ApplicationController
      private

      def user_not_found
        render json: { error: "Пользователь не найден" }, status: :not_found
      end
    end
  end
end
