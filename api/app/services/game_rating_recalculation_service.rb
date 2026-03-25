class GameRatingRecalculationService
  def self.enqueue(game_id)
    game_id = game_id.to_i

    ActiveRecord::Base.transaction do
      recalculation = GameRatingRecalculation.find_by(game_id: game_id, status: GameRatingRecalculation::STATUS_PENDING)

      if recalculation.nil?
        GameRatingRecalculation.create!(
          game_id: game_id,
          status: GameRatingRecalculation::STATUS_PENDING,
          scheduled_at: Time.current
        )
      end
    end

    true
  rescue ActiveRecord::RecordNotUnique
    true
  end

  def self.enqueue_bulk(game_ids)
    game_ids = game_ids.map(&:to_i).uniq

    ActiveRecord::Base.transaction do
      existing_pending = GameRatingRecalculation
        .where(game_id: game_ids, status: GameRatingRecalculation::STATUS_PENDING)
        .pluck(:game_id)

      game_ids_to_enqueue = game_ids - existing_pending

      game_ids_to_enqueue.each do |game_id|
        GameRatingRecalculation.create!(
          game_id: game_id,
          status: GameRatingRecalculation::STATUS_PENDING,
          scheduled_at: Time.current
        )
      end
    end

    true
  rescue ActiveRecord::RecordNotUnique
    true
  end

  def self.process_recalcation_for_game(game_id)
    game = Game.find_by(id: game_id)

    if game.nil?
      Rails.logger.warn "Game #{game_id} not found for recalculation"
      return
    end

    active_reviews = game.reviews.active

    if active_reviews.exists?
      rating_avg = active_reviews.average(:rating).to_f.round(2)
      difficulty_avg = active_reviews.average(:difficulty).to_f.round(2)

      game.update!(
        rating_avg: rating_avg,
        difficulty_avg: difficulty_avg
      )
    else
      game.update!(
        rating_avg: nil,
        difficulty_avg: nil
      )
    end

    Rails.logger.info "Game #{game.id} rating recalculated: rating_avg=#{game.rating_avg}, difficulty_avg=#{game.difficulty_avg}"
  rescue => e
    Rails.logger.error "Failed to recalculate game #{game_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  def self.process_pending
    recalculations = GameRatingRecalculation.for_processing.limit(100)

    recalculations.each do |recalculation|
      process_recalculation(recalculation)
    end
  end

  def self.process_recalculation(recalculation)
    recalculation.update!(status: GameRatingRecalculation::STATUS_PROCESSING)

    game = Game.find_by(id: recalculation.game_id)

    if game.nil?
      recalculation.update!(
        status: GameRatingRecalculation::STATUS_COMPLETED,
        processed_at: Time.current,
        error_message: "Game not found"
      )
      return
    end

    active_reviews = game.reviews.active

    if active_reviews.exists?
      rating_avg = active_reviews.average(:rating).to_f.round(2)
      difficulty_avg = active_reviews.average(:difficulty).to_f.round(2)

      game.update!(
        rating_avg: rating_avg,
        difficulty_avg: difficulty_avg
      )
    else
      game.update!(
        rating_avg: nil,
        difficulty_avg: nil
      )
    end

    recalculation.update!(
      status: GameRatingRecalculation::STATUS_COMPLETED,
      processed_at: Time.current
    )

    Rails.logger.info "Game #{game.id} rating recalculated: rating_avg=#{game.rating_avg}, difficulty_avg=#{game.difficulty_avg}"
  rescue => e
    recalculation.update!(
      status: GameRatingRecalculation::STATUS_FAILED,
      processed_at: Time.current,
      error_message: e.message
    )

    Rails.logger.error "Failed to recalculate game #{recalculation.game_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def self.cleanup_old(days_old: 7)
    cutoff_date = days_old.days.ago

    deleted_count = GameRatingRecalculation
      .where(status: GameRatingRecalculation::STATUS_COMPLETED)
      .where("created_at < ?", cutoff_date)
      .delete_all

    Rails.logger.info "Cleaned up #{deleted_count} old completed recalculations"

    deleted_count
  end
end
