class LinkDeleteService
  class LinkDeleteError < ApplicationService::BaseError; end

  def self.call(link, current_user: nil)
    new(link, current_user).delete
  end

  def self.restore(link, current_user: nil)
    new(link, current_user).restore
  end

  def initialize(link, current_user = nil)
    @link = link
    @current_user = current_user
  end

  def delete
    raise LinkDeleteError, "Link is already disabled" if @link.is_disabled?

    ActiveRecord::Base.transaction do
      @link.update!(is_disabled: true)

      AuditLogService.log_delete(
        user_id: @current_user&.id,
        table_name: "links",
        record_id: @link.id,
        old_values: link_attributes
      )
    end

    @link
  rescue ActiveRecord::RecordInvalid => e
    raise LinkDeleteError, e.message
  end

  def restore
    raise LinkDeleteError, "Link is not disabled" unless @link.is_disabled?

    ActiveRecord::Base.transaction do
      @link.update!(is_disabled: false)

      AuditLogService.log_create(
        user_id: @current_user&.id,
        table_name: "links",
        record_id: @link.id,
        new_values: link_attributes
      )
    end

    @link
  rescue ActiveRecord::RecordInvalid => e
    raise LinkDeleteError, e.message
  end

  private

  def link_attributes
    {
      "game_id" => @link.game_id,
      "link_type" => @link.link_type,
      "url" => @link.url,
      "title" => @link.title,
      "is_disabled" => @link.is_disabled
    }
  end
end
