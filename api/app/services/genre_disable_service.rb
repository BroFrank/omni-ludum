class GenreDisableService
  class GenreDisableError < ApplicationService::BaseError; end

  def self.call(genre, current_user: nil)
    new(genre, current_user).disable
  end

  def self.restore(genre, current_user: nil)
    new(genre, current_user).restore
  end

  def initialize(genre, current_user = nil)
    @genre = genre
    @current_user = current_user
  end

  def disable
    raise GenreDisableError, "Genre is already disabled" if @genre.is_disabled?

    ActiveRecord::Base.transaction do
      @genre.game_genres.active.update_all(is_disabled: true)
      @genre.update!(is_disabled: true)

      AuditLogService.log_delete(
        user_id: @current_user&.id,
        table_name: "genres",
        record_id: @genre.id,
        old_values: genre_attributes
      )
    end

    @genre
  rescue ActiveRecord::RecordInvalid => e
    raise GenreDisableError, e.message
  end

  def restore
    raise GenreDisableError, "Genre is not disabled" unless @genre.is_disabled?

    ActiveRecord::Base.transaction do
      @genre.update!(is_disabled: false)

      AuditLogService.log_create(
        user_id: @current_user&.id,
        table_name: "genres",
        record_id: @genre.id,
        new_values: genre_attributes
      )
    end

    @genre
  rescue ActiveRecord::RecordInvalid => e
    raise GenreDisableError, e.message
  end

  private

  def genre_attributes
    {
      "name" => @genre.name,
      "slug" => @genre.slug,
      "is_disabled" => @genre.is_disabled
    }
  end
end
