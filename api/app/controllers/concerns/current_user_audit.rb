module CurrentUserAudit
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user_id
    after_action :clear_current_user_id
  end

  private

  def set_current_user_id
    Thread.current[:current_user_id] = current_user_id
  end

  def clear_current_user_id
    Thread.current[:current_user_id] = nil
  end

  def current_user_id
    return nil unless respond_to?(:current_user, true)

    current_user&.id
  rescue => e
    Rails.logger.warn "Failed to get current_user: #{e.message}"
    nil
  end
end
