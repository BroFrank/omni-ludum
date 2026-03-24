class ProcessPendingPlaytimeRecalculationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    UsersPlaytimeRecalculationService.process_pending
  end
end
