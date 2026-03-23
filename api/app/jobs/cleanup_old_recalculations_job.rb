class CleanupOldRecalculationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    GameRatingRecalculationService.cleanup_old(days_old: 7)
  end
end
