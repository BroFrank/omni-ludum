module Api
  module V1
    class PublishersController < BaseController
      before_action :set_publisher, only: %i[show update disable]

      def index
        @publishers = Publisher.active.page(params[:page]).per(params[:per_page] || 20)
        render template: "api/v1/publishers/index", status: :ok
      end

      def show
        render template: "api/v1/publishers/show", status: :ok
      end

      def create
        @publisher = Publisher.new(publisher_params)
        if @publisher.save
          render template: "api/v1/publishers/create", status: :created
        else
          render json: { errors: @publisher.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @publisher.update(publisher_params)
          render template: "api/v1/publishers/update", status: :ok
        else
          render json: { errors: @publisher.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def disable
        if @publisher.disable!
          render template: "api/v1/publishers/update", status: :ok
        else
          render json: { errors: @publisher.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_publisher
        @publisher = Publisher.find_by_slug(params[:slug])
        publisher_not_found unless @publisher
      end

      def publisher_not_found
        render json: { error: "Publisher not found" }, status: :not_found
      end

      def publisher_params
        params.require(:publisher).permit(:name, :type, :slug)
      end
    end
  end
end
