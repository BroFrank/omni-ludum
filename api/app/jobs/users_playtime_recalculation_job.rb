class UsersPlaytimeRecalculationJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    recalculation = UsersPlaytimeRecalculation.find_by(game_id: game_id, status: UsersPlaytimeRecalculation::STATUS_PENDING)

    if recalculation
      UsersPlaytimeRecalculationService.process_recalculation(recalculation)
    else
      Rails.logger.warn "No pending recalculation found for game #{game_id}"
    end
  end
end
