require "test_helper"

class GameRatingRecalculationServiceTest < ActiveSupport::TestCase
  setup do
    @game = games(:one)
  end

  test "enqueue creates pending recalculation" do
    assert_difference "GameRatingRecalculation.count", 1 do
      result = GameRatingRecalculationService.enqueue(@game.id)
      assert result
    end

    recalculation = GameRatingRecalculation.last
    assert_equal @game.id, recalculation.game_id
    assert_equal GameRatingRecalculation::STATUS_PENDING, recalculation.status
    assert recalculation.scheduled_at <= Time.current
  end

  test "enqueue does not create duplicate pending recalculation" do
    GameRatingRecalculationService.enqueue(@game.id)
    assert_no_difference "GameRatingRecalculation.count" do
      result = GameRatingRecalculationService.enqueue(@game.id)
      assert result
    end
  end

  test "enqueue handles concurrent requests safely" do
    threads = []
    10.times do
      threads << Thread.new { GameRatingRecalculationService.enqueue(@game.id) }
    end

    threads.each(&:join)

    pending_count = GameRatingRecalculation.where(
      game_id: @game.id,
      status: GameRatingRecalculation::STATUS_PENDING
    ).count

    assert_equal 1, pending_count
  end

  test "enqueue_bulk creates pending recalculations" do
    game_ids = [games(:one).id, games(:two).id]

    assert_difference "GameRatingRecalculation.count", 2 do
      result = GameRatingRecalculationService.enqueue_bulk(game_ids)
      assert result
    end
  end

  test "enqueue_bulk handles duplicates" do
    game_ids = [games(:one).id, games(:one).id, games(:two).id]

    assert_difference "GameRatingRecalculation.count", 2 do
      GameRatingRecalculationService.enqueue_bulk(game_ids)
    end
  end

  test "process_recalculation updates game rating" do
    Review.create!(
      game: @game,
      user: users(:one),
      rating: 8,
      difficulty: 5
    )

    GameRatingRecalculationService.enqueue(@game.id)

    recalculation = GameRatingRecalculation.find_by(
      game_id: @game.id,
      status: GameRatingRecalculation::STATUS_PENDING
    )

    GameRatingRecalculationService.process_recalculation(recalculation)

    @game.reload
    assert_equal 8.0, @game.rating_avg
    assert_equal 5.0, @game.difficulty_avg

    recalculation.reload
    assert_equal GameRatingRecalculation::STATUS_COMPLETED, recalculation.status
    assert recalculation.processed_at <= Time.current
  end

  test "process_recalculation sets nil when no reviews" do
    @game.update!(rating_avg: 5.0, difficulty_avg: 3.0)

    recalculation = GameRatingRecalculation.create!(
      game_id: @game.id,
      status: GameRatingRecalculation::STATUS_PENDING,
      scheduled_at: Time.current
    )

    GameRatingRecalculationService.process_recalculation(recalculation)

    @game.reload
    assert_nil @game.rating_avg
    assert_nil @game.difficulty_avg
  end

  test "cleanup_old removes old completed recalculations" do
    old_completed = GameRatingRecalculation.create!(
      game_id: @game.id,
      status: GameRatingRecalculation::STATUS_COMPLETED,
      scheduled_at: 10.days.ago,
      created_at: 10.days.ago,
      processed_at: 9.days.ago
    )

    recent_completed = GameRatingRecalculation.create!(
      game_id: @game.id,
      status: GameRatingRecalculation::STATUS_COMPLETED,
      scheduled_at: 2.days.ago,
      created_at: 2.days.ago,
      processed_at: 1.day.ago
    )

    pending = GameRatingRecalculation.create!(
      game_id: @game.id,
      status: GameRatingRecalculation::STATUS_PENDING,
      scheduled_at: 10.days.ago
    )

    deleted = GameRatingRecalculationService.cleanup_old(days_old: 7)

    assert_equal 1, deleted
    assert_raises(ActiveRecord::RecordNotFound) { old_completed.reload }
    assert_nothing_raised { recent_completed.reload }
    assert_nothing_raised { pending.reload }
  end
end
