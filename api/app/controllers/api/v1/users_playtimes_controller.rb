module Api
  module V1
    class UsersPlaytimesController < BaseController
      before_action :set_game, only: [ :index, :create ]
      before_action :set_user, only: [ :index ]
      before_action :set_users_playtime, only: [ :show, :update, :destroy ]

      def index
        @users_playtimes = if @game
                             @game.users_playtimes.active.order(created_at: :desc)
        elsif @user
                             @user.users_playtimes.active.includes(:game).order(created_at: :desc)
        else
                             UsersPlaytime.active.includes(:game, :user).order(created_at: :desc)
        end

        @users_playtimes = @users_playtimes.page(params[:page]).per(params[:per_page] || 20)

        render json: @users_playtimes, include: [ :game, :user ], status: :ok
      end

      def show
        render json: @users_playtime, include: [ :game, :user ], status: :ok
      end

      def create
        @users_playtime = UsersPlaytime.new(users_playtime_params)

        if @users_playtime.save
          render json: @users_playtime, include: [ :game, :user ], status: :created
        else
          render_validation_errors(@users_playtime)
        end
      end

      def update
        if @users_playtime.update(users_playtime_params)
          render json: @users_playtime, include: [ :game, :user ], status: :ok
        else
          render_validation_errors(@users_playtime)
        end
      end

      def destroy
        @users_playtime.update!(is_disabled: true)
        render json: { message: "Users playtime successfully deleted" }, status: :ok
      end

      private

      def set_game
        if params[:game_id]
          @game = Game.find_by_name(params[:game_id])
          render_not_found("Game") unless @game
        end
      end

      def set_user
        if params[:user_id]
          @user = User.find_by_slug(params[:user_id])
          render_not_found("User") unless @user
        end
      end

      def set_users_playtime
        @users_playtime = UsersPlaytime.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_not_found("Users playtime")
      end

      def users_playtime_params
        params.require(:users_playtime).permit(:user_id, :game_id, :minutes_regular, :minutes_100)
      end
    end
  end
end
