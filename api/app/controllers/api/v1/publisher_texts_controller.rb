module Api
  module V1
    class PublisherTextsController < BaseController
      before_action :set_publisher_text, only: %i[show update destroy]
      before_action :set_publisher, only: %i[index create]

      def index
        @publisher_texts = @publisher_texts.active.page(params[:page]).per(params[:per_page] || 20)
        render template: "api/v1/publisher_texts/index", status: :ok
      end

      def show
        render template: "api/v1/publisher_texts/show", status: :ok
      end

      def create
        @publisher_text = PublisherText.new(publisher_text_params)
        if @publisher_text.save
          render template: "api/v1/publisher_texts/create", status: :created
        else
          render json: { errors: @publisher_text.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @publisher_text.update(publisher_text_params)
          render template: "api/v1/publisher_texts/update", status: :ok
        else
          render json: { errors: @publisher_text.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @publisher_text.destroy
        head :no_content
      end

      private

      def set_publisher_text
        @publisher_text = PublisherText.find(params[:id])
        publisher_text_not_found unless @publisher_text
      end

      def set_publisher
        if params[:publisher_slug]
          @publisher = Publisher.find_by_slug(params[:publisher_slug])
          if @publisher
            @publisher_texts = @publisher.publisher_texts
          else
            publisher_not_found
          end
        elsif params[:publisher_id]
          @publisher = Publisher.find_by_id(params[:publisher_id])
          if @publisher
            @publisher_texts = @publisher.publisher_texts
          else
            publisher_not_found
          end
        else
          @publisher_texts = PublisherText.all
        end
      end

      def publisher_text_params
        params.require(:publisher_text).permit(:publisher_id, :lang_code, :description)
      end

      def publisher_not_found
        render json: { error: "Publisher not found" }, status: :not_found
      end

      def publisher_text_not_found
        render json: { error: "Publisher text not found" }, status: :not_found
      end
    end
  end
end
