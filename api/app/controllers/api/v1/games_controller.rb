module Api
  module V1
    class GamesController < BaseController
      before_action :set_game, only: %i[show update disable]

      def index
        @games = Game.active
          .includes(:platform, :publisher, :genres)
          .page(params[:page])
          .per(params[:per_page] || DEFAULT_PER_PAGE)
        render template: "api/v1/games/index", status: :ok
      end

      def show
        render template: "api/v1/games/show", status: :ok
      end

      def create
        @game = Game.new(game_params)
        if @game.save
          render template: "api/v1/games/create", status: :created
        else
          render_validation_errors(@game)
        end
      end

      def update
        if @game.update(game_params)
          render template: "api/v1/games/update", status: :ok
        else
          render_validation_errors(@game)
        end
      end

      def disable
        GameDisableService.call(@game, current_user: current_user)
        render template: "api/v1/games/update", status: :ok
      rescue GameDisableService::GameDisableError => e
        render_validation_errors(@game)
      end

      private

      def set_game
        @game = Game.find_by_name(params[:id])
        game_not_found unless @game
      end

      def game_params
        params.require(:game).permit(
          :name,
          :release_year,
          :rating_avg,
          :difficulty_avg,
          :playtime_avg,
          :playtime_100_avg,
          :is_dlc,
          :is_mod,
          :base_game_id,
          :platform_id,
          :publisher_id,
          genre_ids: []
        )
      end
    end
  end
end
