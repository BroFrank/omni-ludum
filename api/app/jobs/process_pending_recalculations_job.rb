class ProcessPendingRecalculationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    GameRatingRecalculationService.process_pending
  end
end
