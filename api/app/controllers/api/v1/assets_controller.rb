module Api
  module V1
    class AssetsController < BaseController
      before_action :set_game, only: %i[index create]
      before_action :set_asset, only: %i[show update destroy download]

      rescue_from AssetUploadService::InvalidFileSizeError,
                  AssetUploadService::InvalidMimeTypeError do |e|
        render_service_error(e.message, :bad_request)
      end

      rescue_from AssetUploadService::ValidationError do |e|
        render_service_error(e.message, :unprocessable_entity)
      end

      rescue_from AssetUploadService::UploadError do |e|
        render_service_error(e.message, :unprocessable_entity)
      end

      rescue_from AssetUploadService::Error do |e|
        render_service_error(e.message, :not_found)
      end

      def index
        @assets = @game.assets.active.ordered
        @assets = @assets.by_type(params[:asset_type]) if params[:asset_type].present?
        @assets = @assets.page(params[:page]).per(params[:per_page] || 20)
        render template: "api/v1/assets/index", status: :ok
      end

      def show
        render template: "api/v1/assets/show", status: :ok
      end

      def create
        @asset = AssetUploadService.upload(
          @game.id,
          params[:file],
          params[:asset_type],
          order_index: params[:order_index]
        )
        render template: "api/v1/assets/create", status: :created, formats: [ :json ]
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: [ e.message ] }, status: :unprocessable_entity
      end

      def update
        if params[:order_index].present?
          @asset.update!(order_index: params[:order_index].to_i)
        end
        render template: "api/v1/assets/update", status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render_validation_errors(@asset)
      end

      def destroy
        AssetUploadService.remove(@asset.id)
        head :no_content
      end

      def download
        url = AssetUploadService.download_url(@asset.id)
        if url
          redirect_to url, allow_other_host: true
        else
          render json: { errors: [ "File not found" ] }, status: :not_found
        end
      end

      private

      def set_game
        @game = Game.find_by_name(params[:game_id] || params[:game_name])
        game_not_found unless @game
      end

      def set_asset
        @asset = Asset.find_by(id: params[:id])
        asset_not_found unless @asset
      end
    end
  end
end
