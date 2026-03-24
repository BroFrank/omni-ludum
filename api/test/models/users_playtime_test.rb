require "test_helper"

class UsersPlaytimeTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @game = games(:one)
  end

  test "should create valid users playtime" do
    users_playtime = UsersPlaytime.new(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: 360
    )
    assert users_playtime.save
  end

  test "should require user_id" do
    users_playtime = UsersPlaytime.new(
      user_id: nil,
      game: @game,
      minutes_regular: 120
    )
    assert_not users_playtime.valid?
    assert_includes users_playtime.errors[:user_id], "can't be blank"
  end

  test "should require game_id" do
    users_playtime = UsersPlaytime.new(
      user: @user,
      game_id: nil,
      minutes_regular: 120
    )
    assert_not users_playtime.valid?
    assert_includes users_playtime.errors[:game_id], "can't be blank"
  end

  test "minutes_regular must be greater than or equal to 0" do
    users_playtime = UsersPlaytime.new(
      user: @user,
      game: @game,
      minutes_regular: -1
    )
    assert_not users_playtime.valid?
    assert_includes users_playtime.errors[:minutes_regular], "must be greater than or equal to 0"
  end

  test "minutes_100 must be greater than or equal to 0" do
    users_playtime = UsersPlaytime.new(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: -1
    )
    assert_not users_playtime.valid?
    assert_includes users_playtime.errors[:minutes_100], "must be greater than or equal to 0"
  end

  test "minutes_regular is optional" do
    users_playtime = UsersPlaytime.new(
      user: @user,
      game: @game,
      minutes_regular: nil,
      minutes_100: 360
    )
    assert users_playtime.valid?
  end

  test "minutes_100 is optional" do
    users_playtime = UsersPlaytime.new(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: nil
    )
    assert users_playtime.valid?
  end

  test "user can only record playtime once (active playtimes)" do
    UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: 360
    )

    duplicate_playtime = UsersPlaytime.new(
      user: @user,
      game: @game,
      minutes_regular: 150,
      minutes_100: 400
    )
    assert_not duplicate_playtime.valid?
    assert_includes duplicate_playtime.errors[:user_id], "has already recorded playtime for this game"
  end

  test "user can create new playtime after disabling previous one" do
    UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: 360,
      is_disabled: true
    )

    new_playtime = UsersPlaytime.new(
      user: @user,
      game: @game,
      minutes_regular: 150,
      minutes_100: 400
    )
    assert new_playtime.valid?
  end

  test "active scope returns only non-disabled playtimes" do
    active_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: 360,
      is_disabled: false
    )

    disabled_playtime = UsersPlaytime.create!(
      user: users(:two),
      game: games(:two),
      minutes_regular: 100,
      minutes_100: 300,
      is_disabled: true
    )

    assert_includes UsersPlaytime.active, active_playtime
    assert_not_includes UsersPlaytime.active, disabled_playtime
  end

  test "disabled scope returns only disabled playtimes" do
    active_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: 360,
      is_disabled: false
    )

    disabled_playtime = UsersPlaytime.create!(
      user: users(:two),
      game: games(:two),
      minutes_regular: 100,
      minutes_100: 300,
      is_disabled: true
    )

    assert_includes UsersPlaytime.disabled, disabled_playtime
    assert_not_includes UsersPlaytime.disabled, active_playtime
  end

  test "should belong to user" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120
    )
    assert_equal @user, users_playtime.user
  end

  test "should belong to game" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120
    )
    assert_equal @game, users_playtime.game
  end

  test "should create game playtime recalculation after create" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120
    )

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: @game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)
    assert_not_nil recalculation
  end

  test "should create game playtime recalculation after minutes_regular update" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120
    )

    users_playtime.update!(minutes_regular: 150)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: @game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)
    assert_not_nil recalculation
  end

  test "should create game playtime recalculation after minutes_100 update" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: 360
    )

    users_playtime.update!(minutes_100: 400)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: @game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)
    assert_not_nil recalculation
  end

  test "should create game playtime recalculation after is_disabled update" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120
    )

    users_playtime.update!(is_disabled: true)

    recalculation = UsersPlaytimeRecalculation.find_by(game_id: @game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING)
    assert_not_nil recalculation
  end

  test "should not create duplicate recalculation if already pending" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120
    )

    users_playtime.update!(minutes_regular: 150)

    users_playtime.update!(minutes_regular: 180)

    count = UsersPlaytimeRecalculation.where(game_id: @game.id, status: UsersPlaytimeRecalculation::STATUS_PENDING).count
    assert_equal 1, count
  end

  test "find_by_user_and_game returns active playtime" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      is_disabled: false
    )

    found_playtime = UsersPlaytime.find_by_user_and_game(@user.id, @game.id)
    assert_equal users_playtime.id, found_playtime.id
  end

  test "find_by_user_and_game returns nil for disabled playtime" do
    users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      is_disabled: true
    )

    found_playtime = UsersPlaytime.find_by_user_and_game(@user.id, @game.id)
    assert_nil found_playtime
  end
end
