module Api
  module V1
    class PlatformsController < BaseController
      before_action :set_platform, only: %i[show]

      def index
        @all_platforms = Platform.active_ordered
        page = params[:page] || 1
        per_page = params[:per_page] || DEFAULT_PER_PAGE

        @platforms = Kaminari.paginate_array(@all_platforms).page(page).per(per_page)
        render template: "api/v1/platforms/index", status: :ok
      end

      def show
        render template: "api/v1/platforms/show", status: :ok
      end

      private

      def set_platform
        @platform = Platform.find_by_slug(params[:slug])
        platform_not_found unless @platform
      end
    end
  end
end
