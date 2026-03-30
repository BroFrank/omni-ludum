class UsersPlaytimeRecalculationService
  def self.enqueue(game_id)
    game_id = game_id.to_i

    ActiveRecord::Base.transaction do
      recalculation = UsersPlaytimeRecalculation.find_by(game_id: game_id, status: UsersPlaytimeRecalculation::STATUS_PENDING)

      if recalculation.nil?
        UsersPlaytimeRecalculation.create!(
          game_id: game_id,
          status: UsersPlaytimeRecalculation::STATUS_PENDING,
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
      existing_pending = UsersPlaytimeRecalculation
        .where(game_id: game_ids, status: UsersPlaytimeRecalculation::STATUS_PENDING)
        .pluck(:game_id)

      game_ids_to_enqueue = game_ids - existing_pending

      game_ids_to_enqueue.each do |game_id|
        UsersPlaytimeRecalculation.create!(
          game_id: game_id,
          status: UsersPlaytimeRecalculation::STATUS_PENDING,
          scheduled_at: Time.current
        )
      end
    end

    true
  rescue ActiveRecord::RecordNotUnique
    true
  end

  def self.process_pending
    recalculations = UsersPlaytimeRecalculation.for_processing.limit(DEFAULT_BATCH_SIZE)

    recalculations.each do |recalculation|
      process_recalculation(recalculation)
    end
  end

  def self.process_recalculation(recalculation)
    recalculation.update!(status: UsersPlaytimeRecalculation::STATUS_PROCESSING)

    game = Game.find_by(id: recalculation.game_id)

    if game.nil?
      recalculation.update!(
        status: UsersPlaytimeRecalculation::STATUS_COMPLETED,
        processed_at: Time.current,
        error_message: "Game not found"
      )
      return
    end

    active_playtimes = game.users_playtimes.active

    if active_playtimes.exists?
      playtime_avg = active_playtimes.average(:minutes_regular).to_i
      playtime_100_avg = active_playtimes.average(:minutes_100).to_i

      game.update!(
        playtime_avg: playtime_avg,
        playtime_100_avg: playtime_100_avg
      )
    else
      game.update!(
        playtime_avg: nil,
        playtime_100_avg: nil
      )
    end

    recalculation.update!(
      status: UsersPlaytimeRecalculation::STATUS_COMPLETED,
      processed_at: Time.current
    )

    Rails.logger.info "Game #{game.id} playtime recalculated: playtime_avg=#{game.playtime_avg}, playtime_100_avg=#{game.playtime_100_avg}"
  rescue => e
    recalculation.update!(
      status: UsersPlaytimeRecalculation::STATUS_FAILED,
      processed_at: Time.current,
      error_message: e.message
    )

    Rails.logger.error "Failed to recalculate playtime for game #{recalculation.game_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def self.cleanup_old(days_old: DEFAULT_CLEANUP_DAYS_OLD)
    cutoff_date = days_old.days.ago

    deleted_count = UsersPlaytimeRecalculation
      .where(status: UsersPlaytimeRecalculation::STATUS_COMPLETED)
      .where("created_at < ?", cutoff_date)
      .delete_all

    Rails.logger.info "Cleaned up #{deleted_count} old completed playtime recalculations"

    deleted_count
  end
end
