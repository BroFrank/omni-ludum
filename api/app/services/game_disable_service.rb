class GameDisableService
  class GameDisableError < ApplicationService::BaseError; end

  def self.call(game, current_user: nil)
    new(game, current_user).disable
  end

  def self.restore(game, current_user: nil)
    new(game, current_user).restore
  end

  def initialize(game, current_user = nil)
    @game = game
    @current_user = current_user
  end

  def disable
    raise GameDisableError, "Game is already disabled" if @game.is_disabled?

    ActiveRecord::Base.transaction do
      @game.dlcs.active.update_all(base_game_id: nil)
      @game.reviews.active.update_all(is_disabled: true)
      @game.users_playtimes.active.update_all(is_disabled: true)

      @game.update!(is_disabled: true)

      AuditLogService.log_delete(
        user_id: @current_user&.id,
        table_name: "games",
        record_id: @game.id,
        old_values: game_attributes
      )
    end

    @game
  rescue ActiveRecord::RecordInvalid => e
    raise GameDisableError, e.message
  end

  def restore
    raise GameDisableError, "Game is not disabled" unless @game.is_disabled?

    ActiveRecord::Base.transaction do
      @game.update!(is_disabled: false)

      AuditLogService.log_create(
        user_id: @current_user&.id,
        table_name: "games",
        record_id: @game.id,
        new_values: game_attributes
      )
    end

    @game
  rescue ActiveRecord::RecordInvalid => e
    raise GameDisableError, e.message
  end

  private

  def game_attributes
    {
      "name" => @game.name,
      "release_year" => @game.release_year,
      "is_dlc" => @game.is_dlc,
      "is_mod" => @game.is_mod,
      "base_game_id" => @game.base_game_id,
      "platform_id" => @game.platform_id,
      "publisher_id" => @game.publisher_id,
      "is_disabled" => @game.is_disabled
    }
  end
end
