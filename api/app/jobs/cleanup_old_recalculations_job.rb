class CleanupOldRecalculationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    GameRatingRecalculationService.cleanup_old(days_old: DEFAULT_CLEANUP_DAYS_OLD)
  end
end
