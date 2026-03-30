class UserDisableService
  class UserDisableError < ApplicationService::BaseError; end

  def self.call(user, current_user: nil)
    new(user, current_user).disable
  end

  def self.restore(user, current_user: nil)
    new(user, current_user).restore
  end

  def initialize(user, current_user = nil)
    @user = user
    @current_user = current_user
  end

  def disable
    raise UserDisableError, "User is already disabled" if @user.is_disabled?

    ActiveRecord::Base.transaction do
      @user.reviews.active.update_all(is_disabled: true)
      @user.users_playtimes.active.update_all(is_disabled: true)

      @user.update!(is_disabled: true)

      AuditLogService.log_delete(
        user_id: @current_user&.id,
        table_name: "users",
        record_id: @user.id,
        old_values: user_attributes
      )
    end

    @user
  rescue ActiveRecord::RecordInvalid => e
    raise UserDisableError, e.message
  end

  def restore
    raise UserDisableError, "User is not disabled" unless @user.is_disabled?

    ActiveRecord::Base.transaction do
      @user.update!(is_disabled: false)

      AuditLogService.log_create(
        user_id: @current_user&.id,
        table_name: "users",
        record_id: @user.id,
        new_values: user_attributes
      )
    end

    @user
  rescue ActiveRecord::RecordInvalid => e
    raise UserDisableError, e.message
  end

  private

  def user_attributes
    {
      "username" => @user.username,
      "email" => @user.email,
      "role" => @user.role,
      "theme" => @user.theme,
      "locale" => @user.locale,
      "is_disabled" => @user.is_disabled
    }
  end
end
