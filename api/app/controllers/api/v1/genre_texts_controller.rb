module Api
  module V1
    class GenreTextsController < BaseController
      before_action :set_genre_text, only: %i[show update destroy]
      before_action :set_genre, only: %i[index create]

      def index
        @genre_texts = @genre_texts.active
          .includes(:genre)
          .page(params[:page])
          .per(params[:per_page] || DEFAULT_PER_PAGE)
        render template: "api/v1/genre_texts/index", status: :ok
      end

      def show
        render template: "api/v1/genre_texts/show", status: :ok
      end

      def create
        @genre_text = GenreText.new(genre_text_params)
        if @genre_text.save
          render template: "api/v1/genre_texts/create", status: :created
        else
          render_validation_errors(@genre_text)
        end
      end

      def update
        if @genre_text.update(genre_text_params)
          render template: "api/v1/genre_texts/update", status: :ok
        else
          render_validation_errors(@genre_text)
        end
      end

      def destroy
        @genre_text.destroy
        head :no_content
      end

      private

      def set_genre_text
        @genre_text = GenreText.find_by(id: params[:id])
        render_not_found("Genre text") unless @genre_text
      end

      def set_genre
        if params[:genre_slug]
          @genre = Genre.find_by_slug(params[:genre_slug])
          if @genre
            @genre_texts = @genre.genre_texts
          else
            genre_not_found
          end
        elsif params[:genre_id]
          @genre = Genre.find_by_id(params[:genre_id])
          if @genre
            @genre_texts = @genre.genre_texts
          else
            genre_not_found
          end
        else
          @genre_texts = GenreText.all
        end
      end

      def genre_text_params
        params.require(:genre_text).permit(:genre_id, :lang_code, :description)
      end
    end
  end
end
