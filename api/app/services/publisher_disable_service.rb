class PublisherDisableService
  class PublisherDisableError < ApplicationService::BaseError; end

  def self.call(publisher, current_user: nil)
    new(publisher, current_user).disable
  end

  def self.restore(publisher, current_user: nil)
    new(publisher, current_user).restore
  end

  def initialize(publisher, current_user = nil)
    @publisher = publisher
    @current_user = current_user
  end

  def disable
    raise PublisherDisableError, "Publisher is already disabled" if @publisher.is_disabled?

    ActiveRecord::Base.transaction do
      @publisher.games.update_all(publisher_id: nil)
      @publisher.update!(is_disabled: true)

      AuditLogService.log_delete(
        user_id: @current_user&.id,
        table_name: "publishers",
        record_id: @publisher.id,
        old_values: publisher_attributes
      )
    end

    @publisher
  rescue ActiveRecord::RecordInvalid => e
    raise PublisherDisableError, e.message
  end

  def restore
    raise PublisherDisableError, "Publisher is not disabled" unless @publisher.is_disabled?

    ActiveRecord::Base.transaction do
      @publisher.update!(is_disabled: false)

      AuditLogService.log_create(
        user_id: @current_user&.id,
        table_name: "publishers",
        record_id: @publisher.id,
        new_values: publisher_attributes
      )
    end

    @publisher
  rescue ActiveRecord::RecordInvalid => e
    raise PublisherDisableError, e.message
  end

  private

  def publisher_attributes
    {
      "name" => @publisher.name,
      "type" => @publisher.type,
      "slug" => @publisher.slug,
      "is_disabled" => @publisher.is_disabled
    }
  end
end
