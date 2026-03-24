class CleanupOldPlaytimeRecalculationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    UsersPlaytimeRecalculationService.cleanup_old(days_old: 7)
  end
end
