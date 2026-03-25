module Api
  module V1
    class AssetsController < BaseController
      before_action :set_game, only: %i[index create]
      before_action :set_asset, only: %i[show update destroy download]

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
      rescue AssetUploadService::InvalidFileSizeError,
             AssetUploadService::InvalidMimeTypeError => e
        render json: { errors: [ e.message ] }, status: :bad_request
      rescue AssetUploadService::UploadError => e
        render json: { errors: [ e.message ] }, status: :unprocessable_entity
      rescue AssetUploadService::Error => e
        render json: { errors: [ e.message ] }, status: :not_found
      end

      def update
        if params[:order_index].present?
          @asset.update!(order_index: params[:order_index].to_i)
        end
        render template: "api/v1/assets/update", status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: @asset.errors.full_messages }, status: :unprocessable_entity
      end

      def destroy
        AssetUploadService.remove(@asset.id)
        head :no_content
      rescue AssetUploadService::Error => e
        render json: { errors: [ e.message ] }, status: :not_found
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
