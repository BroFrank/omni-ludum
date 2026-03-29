module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [ :show, :update, :disable, :update_theme, :update_locale ]

      def index
        @users = User.active.page(params[:page]).per(params[:per_page] || 20)
        render template: "api/v1/users/index", status: :ok
      end

      def show
        render template: "api/v1/users/show", status: :ok
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render template: "api/v1/users/create", status: :created
        else
          render_validation_errors(@user)
        end
      end

      def update
        if @user.update(user_params)
          render template: "api/v1/users/update", status: :ok
        else
          render_validation_errors(@user)
        end
      end

      def disable
        if @user.update(is_disabled: true)
          render template: "api/v1/users/update", status: :ok
        else
          render_validation_errors(@user)
        end
      end

      def update_theme
        if @user.update(theme: theme_params[:theme])
          render template: "api/v1/users/update", status: :ok
        else
          render_validation_errors(@user, status: :bad_request)
        end
      end

      def update_locale
        if @user.update(locale: locale_params[:locale])
          render template: "api/v1/users/update", status: :ok
        else
          render_validation_errors(@user, status: :bad_request)
        end
      end

      private

      def set_user
        @user = User.find_by_slug(params[:id])
        user_not_found unless @user
      end

      def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :role, :theme, :locale)
      end

      def theme_params
        params.permit(:theme)
      end

      def locale_params
        params.permit(:locale)
      end
    end
  end
end
