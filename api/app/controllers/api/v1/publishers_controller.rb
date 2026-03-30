module Api
  module V1
    class PublishersController < BaseController
      before_action :set_publisher, only: %i[show update disable]

      def index
        @publishers = Publisher.active
          .includes(:publisher_texts, :games)
          .page(params[:page])
          .per(params[:per_page] || DEFAULT_PER_PAGE)
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
          render_validation_errors(@publisher)
        end
      end

      def update
        if @publisher.update(publisher_params)
          render template: "api/v1/publishers/update", status: :ok
        else
          render_validation_errors(@publisher)
        end
      end

      def disable
        PublisherDisableService.call(@publisher, current_user: current_user)
        render template: "api/v1/publishers/update", status: :ok
      rescue PublisherDisableService::PublisherDisableError => e
        render_validation_errors(@publisher)
      end

      private

      def set_publisher
        @publisher = Publisher.find_by_slug(params[:slug])
        publisher_not_found unless @publisher
      end

      def publisher_params
        params.require(:publisher).permit(:name, :type, :slug)
      end
    end
  end
end
