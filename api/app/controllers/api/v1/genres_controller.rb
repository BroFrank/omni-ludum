module Api
  module V1
    class GenresController < BaseController
      before_action :set_genre, only: %i[show update disable]

      def index
        @all_genres = Genre.active_ordered
        page = params[:page] || 1
        per_page = params[:per_page] || DEFAULT_PER_PAGE

        @genres = Kaminari.paginate_array(@all_genres).page(page).per(per_page)
        render template: "api/v1/genres/index", status: :ok
      end

      def show
        render template: "api/v1/genres/show", status: :ok
      end

      def create
        @genre = Genre.new(genre_params)
        if @genre.save
          render template: "api/v1/genres/create", status: :created
        else
          render_validation_errors(@genre)
        end
      end

      def update
        if @genre.update(genre_params)
          render template: "api/v1/genres/update", status: :ok
        else
          render_validation_errors(@genre)
        end
      end

      def disable
        GenreDisableService.call(@genre, current_user: current_user)
        render template: "api/v1/genres/update", status: :ok
      rescue GenreDisableService::GenreDisableError => e
        render_validation_errors(@genre)
      end

      private

      def set_genre
        @genre = Genre.find_by_slug(params[:slug])
        genre_not_found unless @genre
      end

      def genre_params
        params.require(:genre).permit(:name, :slug)
      end
    end
  end
end
