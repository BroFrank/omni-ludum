module Api
  module V1
    class GameTextsController < BaseController
      before_action :set_game_text, only: %i[show update destroy]
      before_action :set_game, only: %i[index create]

      def index
        @game_texts = @game_texts.active.page(params[:page]).per(params[:per_page] || 20)
        render template: "api/v1/game_texts/index", status: :ok
      end

      def show
        render template: "api/v1/game_texts/show", status: :ok
      end

      def create
        @game_text = GameText.new(game_text_params)
        if @game_text.save
          render template: "api/v1/game_texts/create", status: :created
        else
          render json: { errors: @game_text.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @game_text.update(game_text_params)
          render template: "api/v1/game_texts/update", status: :ok
        else
          render json: { errors: @game_text.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @game_text.destroy
        head :no_content
      end

      private

      def set_game_text
        @game_text = GameText.find(params[:id])
        game_text_not_found unless @game_text
      end

      def set_game
        if params[:game_id]
          @game = Game.find_by_name(params[:game_id])
          if @game
            @game_texts = @game.game_texts
          else
            game_not_found
          end
        else
          @game_texts = GameText.all
        end
      end

      def game_text_params
        params.require(:game_text).permit(:game_id, :lang_code, :description, :trivia)
      end

      def game_not_found
        render json: { error: "Game not found" }, status: :not_found
      end

      def game_text_not_found
        render json: { error: "Game text not found" }, status: :not_found
      end
    end
  end
end
