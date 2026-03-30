require "test_helper"

class UsersPlaytimeRecalculationServiceTest < ActiveSupport::TestCase
  setup do
    @game = games(:one)
  end

  test "enqueue creates pending recalculation" do
    assert_difference "UsersPlaytimeRecalculation.count", 1 do
      result = UsersPlaytimeRecalculationService.enqueue(@game.id)
      assert result
    end

    recalculation = UsersPlaytimeRecalculation.last
    assert_equal @game.id, recalculation.game_id
    assert_equal UsersPlaytimeRecalculation::STATUS_PENDING, recalculation.status
    assert recalculation.scheduled_at <= Time.current
  end

  test "enqueue does not create duplicate pending recalculation" do
    UsersPlaytimeRecalculationService.enqueue(@game.id)
    assert_no_difference "UsersPlaytimeRecalculation.count" do
      result = UsersPlaytimeRecalculationService.enqueue(@game.id)
      assert result
    end
  end

  test "enqueue handles concurrent requests safely" do
    threads = []
    10.times do
      threads << Thread.new { UsersPlaytimeRecalculationService.enqueue(@game.id) }
    end

    threads.each(&:join)

    pending_count = UsersPlaytimeRecalculation.where(
      game_id: @game.id,
      status: UsersPlaytimeRecalculation::STATUS_PENDING
    ).count

    assert_equal 1, pending_count
  end

  test "enqueue_bulk creates pending recalculations" do
    game_ids = [games(:one).id, games(:two).id]

    assert_difference "UsersPlaytimeRecalculation.count", 2 do
      result = UsersPlaytimeRecalculationService.enqueue_bulk(game_ids)
      assert result
    end
  end

  test "enqueue_bulk handles duplicates" do
    game_ids = [games(:one).id, games(:one).id, games(:two).id]

    assert_difference "UsersPlaytimeRecalculation.count", 2 do
      UsersPlaytimeRecalculationService.enqueue_bulk(game_ids)
    end
  end

  test "process_recalculation updates game playtime" do
    UsersPlaytime.create!(
      game: @game,
      user: users(:one),
      minutes_regular: 120,
      minutes_100: 180
    )

    UsersPlaytimeRecalculationService.enqueue(@game.id)

    recalculation = UsersPlaytimeRecalculation.find_by(
      game_id: @game.id,
      status: UsersPlaytimeRecalculation::STATUS_PENDING
    )

    UsersPlaytimeRecalculationService.process_recalculation(recalculation)

    @game.reload
    assert_equal 120, @game.playtime_avg
    assert_equal 180, @game.playtime_100_avg

    recalculation.reload
    assert_equal UsersPlaytimeRecalculation::STATUS_COMPLETED, recalculation.status
    assert recalculation.processed_at <= Time.current
  end

  test "process_recalculation sets nil when no playtimes" do
    @game.update!(playtime_avg: 100, playtime_100_avg: 150)

    recalculation = UsersPlaytimeRecalculation.create!(
      game_id: @game.id,
      status: UsersPlaytimeRecalculation::STATUS_PENDING,
      scheduled_at: Time.current
    )

    UsersPlaytimeRecalculationService.process_recalculation(recalculation)

    @game.reload
    assert_nil @game.playtime_avg
    assert_nil @game.playtime_100_avg
  end

  test "cleanup_old removes old completed recalculations" do
    old_completed = UsersPlaytimeRecalculation.create!(
      game_id: @game.id,
      status: UsersPlaytimeRecalculation::STATUS_COMPLETED,
      scheduled_at: 10.days.ago,
      created_at: 10.days.ago,
      processed_at: 9.days.ago
    )

    recent_completed = UsersPlaytimeRecalculation.create!(
      game_id: @game.id,
      status: UsersPlaytimeRecalculation::STATUS_COMPLETED,
      scheduled_at: 2.days.ago,
      created_at: 2.days.ago,
      processed_at: 1.day.ago
    )

    pending = UsersPlaytimeRecalculation.create!(
      game_id: @game.id,
      status: UsersPlaytimeRecalculation::STATUS_PENDING,
      scheduled_at: 10.days.ago
    )

    deleted = UsersPlaytimeRecalculationService.cleanup_old(days_old: 7)

    assert_equal 1, deleted
    assert_raises(ActiveRecord::RecordNotFound) { old_completed.reload }
    assert_nothing_raised { recent_completed.reload }
    assert_nothing_raised { pending.reload }
  end
end
