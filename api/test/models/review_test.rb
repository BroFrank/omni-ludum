require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @game = games(:one)
  end

  test "should create valid review" do
    review = Review.new(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5,
      comment: "Great game!"
    )
    assert review.save
  end

  test "should require user_id" do
    review = Review.new(
      user_id: nil,
      game: @game,
      rating: 8,
      difficulty: 5
    )
    assert_not review.valid?
    assert_includes review.errors[:user], "must exist"
  end

  test "should require game_id" do
    review = Review.new(
      user: @user,
      game_id: nil,
      rating: 8,
      difficulty: 5
    )
    assert_not review.valid?
    assert_includes review.errors[:game], "must exist"
  end

  test "should require rating" do
    review = Review.new(
      user: @user,
      game: @game,
      rating: nil,
      difficulty: 5
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], "can't be blank"
  end

  test "should require difficulty" do
    review = Review.new(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: nil
    )
    assert_not review.valid?
    assert_includes review.errors[:difficulty], "can't be blank"
  end

  test "rating must be between 0 and 10" do
    review = Review.new(
      user: @user,
      game: @game,
      rating: 11,
      difficulty: 5
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], "must be between 0 and 10"

    review.rating = -1
    assert_not review.valid?
    assert_includes review.errors[:rating], "must be between 0 and 10"
  end

  test "difficulty must be between 0 and 10" do
    review = Review.new(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 11
    )
    assert_not review.valid?
    assert_includes review.errors[:difficulty], "must be between 0 and 10"

    review.difficulty = -1
    assert_not review.valid?
    assert_includes review.errors[:difficulty], "must be between 0 and 10"
  end

  test "comment is optional" do
    review = Review.new(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5,
      comment: nil
    )
    assert review.valid?
  end

  test "comment must not exceed 10000 characters" do
    review = Review.new(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5,
      comment: "a" * 10001
    )
    assert_not review.valid?
    assert review.errors[:comment].any? { |msg| msg.include?("too long") }
  end

  test "user can only review a game once (active reviews)" do
    Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5,
      comment: "First review"
    )

    duplicate_review = Review.new(
      user: @user,
      game: @game,
      rating: 9,
      difficulty: 6
    )
    assert_not duplicate_review.valid?
    assert_includes duplicate_review.errors[:user_id], "has already reviewed this game"
  end

  test "user can create new review after disabling previous one" do
    Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5,
      is_disabled: true
    )

    new_review = Review.new(
      user: @user,
      game: @game,
      rating: 9,
      difficulty: 6
    )
    assert new_review.valid?
  end

  test "active scope returns only non-disabled reviews" do
    active_review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5,
      is_disabled: false
    )

    disabled_review = Review.create!(
      user: users(:two),
      game: games(:two),
      rating: 7,
      difficulty: 4,
      is_disabled: true
    )

    assert_includes Review.active, active_review
    assert_not_includes Review.active, disabled_review
  end

  test "disabled scope returns only disabled reviews" do
    active_review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5,
      is_disabled: false
    )

    disabled_review = Review.create!(
      user: users(:two),
      game: games(:two),
      rating: 7,
      difficulty: 4,
      is_disabled: true
    )

    assert_includes Review.disabled, disabled_review
    assert_not_includes Review.disabled, active_review
  end

  test "should belong to user" do
    review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5
    )
    assert_equal @user, review.user
  end

  test "should belong to game" do
    review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5
    )
    assert_equal @game, review.game
  end

  test "should create game rating recalculation after create" do
    review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5
    )

    recalculation = GameRatingRecalculation.find_by(game_id: @game.id, status: GameRatingRecalculation::STATUS_PENDING)
    assert_not_nil recalculation
  end

  test "should create game rating recalculation after rating update" do
    review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5
    )

    review.update!(rating: 9)

    recalculation = GameRatingRecalculation.find_by(game_id: @game.id, status: GameRatingRecalculation::STATUS_PENDING)
    assert_not_nil recalculation
  end

  test "should create game rating recalculation after difficulty update" do
    review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5
    )

    review.update!(difficulty: 7)

    recalculation = GameRatingRecalculation.find_by(game_id: @game.id, status: GameRatingRecalculation::STATUS_PENDING)
    assert_not_nil recalculation
  end

  test "should not create duplicate recalculation if already pending" do
    review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5
    )

    review.update!(rating: 9)

    review.update!(rating: 10)

    count = GameRatingRecalculation.where(game_id: @game.id, status: GameRatingRecalculation::STATUS_PENDING).count
    assert_equal 1, count
  end
end
