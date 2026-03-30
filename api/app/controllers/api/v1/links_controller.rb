module Api
  module V1
    class LinksController < BaseController
      before_action :set_link, only: %i[show update destroy]
      before_action :set_game, only: %i[index create]

      def index
        if @game
          @links = Link.active.where(game: @game).page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)
        else
          @links = Link.active.page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)
        end
        render template: "api/v1/links/index", status: :ok
      end

      def show
        render template: "api/v1/links/show", status: :ok
      end

      def create
        @link = Link.new(link_params)
        if @game
          @link.game = @game
        end
        if @link.save
          render template: "api/v1/links/create", status: :created
        else
          render_validation_errors(@link)
        end
      end

      def update
        if @link.update(link_params)
          render template: "api/v1/links/update", status: :ok
        else
          render_validation_errors(@link)
        end
      end

      def destroy
        @link.disable!
        head :no_content
      end

      private

      def set_link
        @link = Link.find_by(id: params[:id])
        render_not_found("Link") unless @link
      end

      def set_game
        return unless params[:game_id]
        @game = Game.find_by_name(params[:game_id])
        game_not_found unless @game
      end

      def link_params
        params.require(:link).permit(:link_type, :url, :title, :game_id)
      end
    end
  end
end
