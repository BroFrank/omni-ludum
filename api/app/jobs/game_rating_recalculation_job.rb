class GameRatingRecalculationJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    GameRatingRecalculationService.process_recalcation_for_game(game_id)
  end
end
