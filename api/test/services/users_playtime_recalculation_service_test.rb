require "test_helper"

class UsersPlaytimeRecalculationServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user2 = users(:two)

    UsersPlaytimeRecalculation.delete_all
  end

  test "enqueue creates pending recalculation" do
    game = Game.create!(name: "Test Game Enqueue #{SecureRandom.uuid}", release_year: 2022)

    UsersPlaytimeRecalculationService.enqueue(game.id)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)
    assert_not_nil recalculation
    assert_equal game.id, recalculation.game_id
  end

  test "enqueue does not create duplicate pending recalculation" do
    game = Game.create!(name: "Test Game Enqueue Dup #{SecureRandom.uuid}", release_year: 2022)

    UsersPlaytimeRecalculationService.enqueue(game.id)
    UsersPlaytimeRecalculationService.enqueue(game.id)

    count = UsersPlaytimeRecalculation.where(game_id: game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING).count
    assert_equal 1, count
  end

  test "enqueue_bulk creates pending recalculations for multiple games" do
    game1 = Game.create!(name: "Test Game Bulk 1 #{SecureRandom.uuid}", release_year: 2022)
    game2 = Game.create!(name: "Test Game Bulk 2 #{SecureRandom.uuid}", release_year: 2022)
    game_ids = [ game1.id, game2.id ]

    UsersPlaytimeRecalculationService.enqueue_bulk(game_ids)

    count = UsersPlaytimeRecalculation.where(status: UsersPlaytimeRecalculation::STATUS_PENDING).count
    assert_equal 2, count
  end

  test "enqueue_bulk does not create duplicates for existing pending recalculations" do
    game1 = Game.create!(name: "Test Game Bulk Existing 1 #{SecureRandom.uuid}", release_year: 2022)
    game2 = Game.create!(name: "Test Game Bulk Existing 2 #{SecureRandom.uuid}", release_year: 2022)

    UsersPlaytimeRecalculationService.enqueue(game1.id)

    UsersPlaytimeRecalculationService.enqueue_bulk([ game1.id, game2.id ])

    count = UsersPlaytimeRecalculation.where(game_id: game1.id, status: UsersPlaytimeRecalculation::STATUS_PENDING).count
    assert_equal 1, count

    count2 = UsersPlaytimeRecalculation.where(game_id: game2.id, status: UsersPlaytimeRecalculation::STATUS_PENDING).count
    assert_equal 1, count2
  end

  test "process_recalculation calculates average playtime" do
    game = Game.create!(name: "Test Game Playtime #{SecureRandom.uuid}", release_year: 2022)

    UsersPlaytime.create!(
      user: @user,
      game: game,
      minutes_regular: 120,
      minutes_100: 360
    )

    UsersPlaytime.create!(
      user: @user2,
      game: game,
      minutes_regular: 180,
      minutes_100: 420
    )

    UsersPlaytimeRecalculationService.enqueue(game.id)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)

    UsersPlaytimeRecalculationService.process_recalculation(recalculation)

    game.reload
    assert_equal 150, game.playtime_avg
    assert_equal 390, game.playtime_100_avg
  end

  test "process_recalculation sets nil when no active playtimes" do
    game = Game.create!(name: "Test Game No Playtime #{SecureRandom.uuid}", release_year: 2023)
    game.update!(playtime_avg: 120, playtime_100_avg: 360)

    UsersPlaytimeRecalculationService.enqueue(game.id)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)

    UsersPlaytimeRecalculationService.process_recalculation(recalculation)

    game.reload
    assert_nil game.playtime_avg
    assert_nil game.playtime_100_avg
  end

  test "process_recalculation ignores disabled playtimes" do
    game = Game.create!(name: "Test Game Disabled #{SecureRandom.uuid}", release_year: 2024)

    UsersPlaytime.create!(
      user: @user,
      game: game,
      minutes_regular: 120,
      minutes_100: 360,
      is_disabled: true
    )

    UsersPlaytimeRecalculationService.enqueue(game.id)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)

    UsersPlaytimeRecalculationService.process_recalculation(recalculation)

    game.reload
    assert_nil game.playtime_avg
    assert_nil game.playtime_100_avg
  end

  test "process_recalculation updates recalculation status to completed" do
    game = Game.create!(name: "Test Game Status #{SecureRandom.uuid}", release_year: 2025)

    UsersPlaytime.create!(
      user: @user,
      game: game,
      minutes_regular: 120
    )

    UsersPlaytimeRecalculationService.enqueue(game.id)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)

    UsersPlaytimeRecalculationService.process_recalculation(recalculation)

    recalculation.reload
    assert_equal UsersPlaytimeRecalculation::STATUS_COMPLETED, recalculation.status
    assert_not_nil recalculation.processed_at
  end

  test "process_pending processes multiple pending recalculations" do
    game1 = Game.create!(name: "Test Game 1 #{SecureRandom.uuid}", release_year: 2020)
    game2 = Game.create!(name: "Test Game 2 #{SecureRandom.uuid}", release_year: 2021)

    UsersPlaytimeRecalculationService.enqueue(game1.id)
    UsersPlaytimeRecalculationService.enqueue(game2.id)

    recalculation1 = UsersPlaytimeRecalculation.find_by(game_id: game1.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)
    recalculation2 = UsersPlaytimeRecalculation.find_by(game_id: game2.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)

    recalculation1.update!(scheduled_at: 10.minutes.ago)
    recalculation2.update!(scheduled_at: 10.minutes.ago)

    UsersPlaytime.create!(
      user: @user,
      game: game1,
      minutes_regular: 120
    )

    UsersPlaytimeRecalculationService.process_pending

    recalculation1.reload
    recalculation2.reload

    assert_equal UsersPlaytimeRecalculation::STATUS_COMPLETED, recalculation1.status
    assert_equal UsersPlaytimeRecalculation::STATUS_COMPLETED, recalculation2.status
  end

  test "cleanup_old removes old completed recalculations" do
    game1 = Game.create!(name: "Test Game Cleanup 1 #{SecureRandom.uuid}", release_year: 2020)
    game2 = Game.create!(name: "Test Game Cleanup 2 #{SecureRandom.uuid}", release_year: 2021)

    old_completed = UsersPlaytimeRecalculation.create!(
      game: game1,
      status: UsersPlaytimeRecalculation::STATUS_COMPLETED,
      scheduled_at: 10.days.ago,
      processed_at: 9.days.ago,
      created_at: 10.days.ago
    )

    recent_completed = UsersPlaytimeRecalculation.create!(
      game: game2,
      status: UsersPlaytimeRecalculation::STATUS_COMPLETED,
      scheduled_at: 2.days.ago,
      processed_at: 1.day.ago,
      created_at: 2.days.ago
    )

    UsersPlaytimeRecalculationService.cleanup_old(days_old: 7)

    assert_raises(ActiveRecord::RecordNotFound) { old_completed.reload }
    assert_nothing_raised { recent_completed.reload }
  end
end
