class UsersPlaytimeDeleteService
  class UsersPlaytimeDeleteError < ApplicationService::BaseError; end

  def self.call(users_playtime, current_user: nil)
    new(users_playtime, current_user).delete
  end

  def initialize(users_playtime, current_user = nil)
    @users_playtime = users_playtime
    @current_user = current_user
  end

  def delete
    raise UsersPlaytimeDeleteError, "UsersPlaytime is already disabled" if @users_playtime.is_disabled?

    ActiveRecord::Base.transaction do
      old_values = users_playtime_attributes

      @users_playtime.update!(is_disabled: true)

      AuditLogService.log_delete(
        user_id: @current_user&.id,
        table_name: "users_playtimes",
        record_id: @users_playtime.id,
        old_values: old_values
      )

      UsersPlaytimeRecalculationJob.perform_later(@users_playtime.game_id)
    end

    @users_playtime
  rescue ActiveRecord::RecordInvalid => e
    raise UsersPlaytimeDeleteError, e.message
  end

  private

  def users_playtime_attributes
    {
      "user_id" => @users_playtime.user_id,
      "game_id" => @users_playtime.game_id,
      "minutes_regular" => @users_playtime.minutes_regular,
      "minutes_100" => @users_playtime.minutes_100,
      "is_disabled" => @users_playtime.is_disabled
    }
  end
end
