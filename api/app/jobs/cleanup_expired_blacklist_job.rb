class CleanupExpiredBlacklistJob < ApplicationJob
  queue_as :default

  def perform(*args)
    destroyed = AccessTokenBlacklist.cleanup_old(7.days)
    Rails.logger.debug "Cleanup expired blacklist: #{destroyed} records destroyed"
  end
end
