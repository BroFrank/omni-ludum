require "test_helper"

class GameTextTest < ActiveSupport::TestCase
  setup do
    @game = Game.create!(name: "Test Game", release_year: 2024)
    @valid_attrs = {
      game: @game,
      lang_code: "en",
      description: "Test description",
      trivia: "Test trivia"
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates game_text with valid attributes" do
    gt = GameText.new(@valid_attrs)
    assert gt.valid?
  end

  test "game_id must be present" do
    gt = GameText.new(@valid_attrs.merge(game: nil))
    assert_not gt.valid?
    assert gt.errors.added?(:game, :blank)
  end

  test "lang_code must be present" do
    gt = GameText.new(@valid_attrs.merge(lang_code: nil))
    assert_not gt.valid?
    assert gt.errors.added?(:lang_code, :blank)
  end

  test "lang_code must be exactly 2 characters" do
    gt = GameText.new(@valid_attrs.merge(lang_code: "e"))
    assert_not gt.valid?
    assert gt.errors[:lang_code].any?

    gt = GameText.new(@valid_attrs.merge(lang_code: "eng"))
    assert_not gt.valid?
    assert gt.errors[:lang_code].any?
  end

  test "lang_code must be lowercase latin letters" do
    gt = GameText.new(@valid_attrs.merge(lang_code: "e1"))
    assert_not gt.valid?
    assert gt.errors[:lang_code].any?

    gt = GameText.new(@valid_attrs.merge(lang_code: "1n"))
    assert_not gt.valid?
    assert gt.errors[:lang_code].any?
  end

  test "description can be nil" do
    gt = GameText.new(@valid_attrs.merge(description: nil))
    assert gt.valid?
  end

  test "description has maximum length of 10000 characters" do
    gt = GameText.new(@valid_attrs.merge(description: "a" * 10001))
    assert_not gt.valid?
    assert gt.errors[:description].any?

    gt = GameText.new(@valid_attrs.merge(description: "a" * 10000))
    assert gt.valid?
  end

  test "trivia can be nil" do
    gt = GameText.new(@valid_attrs.merge(trivia: nil))
    assert gt.valid?
  end

  test "trivia has maximum length of 10000 characters" do
    gt = GameText.new(@valid_attrs.merge(trivia: "a" * 10001))
    assert_not gt.valid?
    assert gt.errors[:trivia].any?

    gt = GameText.new(@valid_attrs.merge(trivia: "a" * 10000))
    assert gt.valid?
  end

  test "lang_code is unique per game_id (case-insensitive)" do
    GameText.create!(@valid_attrs)

    gt = GameText.new(@valid_attrs)
    assert_not gt.valid?
    assert_includes gt.errors.full_messages, "Lang code has already been taken"
  end

  test "same lang_code is allowed for different games" do
    game2 = Game.create!(name: "Another Game", release_year: 2023)
    GameText.create!(@valid_attrs)
    gt = GameText.new(@valid_attrs.merge(game: game2))
    assert gt.valid?
  end

  # ============================================
  # Lang code normalization
  # ============================================
  test "lang_code is normalized to lowercase" do
    gt = GameText.create!(@valid_attrs.merge(lang_code: "EN"))
    assert_equal "en", gt.lang_code
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only texts for active games" do
    active_game = Game.create!(name: "Active Game", release_year: 2024)
    disabled_game = Game.create!(name: "Disabled Game", release_year: 2023, is_disabled: true)

    active_gt = GameText.create!(@valid_attrs.merge(game: active_game))
    disabled_gt = GameText.create!(@valid_attrs.merge(game: disabled_game, lang_code: "ru"))

    assert_includes GameText.active, active_gt
    assert_not_includes GameText.active, disabled_gt
  end

  test "by_lang scope filters by language" do
    en_gt = GameText.create!(@valid_attrs)
    ru_gt = GameText.create!(@valid_attrs.merge(lang_code: "ru"))

    assert_includes GameText.by_lang("en"), en_gt
    assert_not_includes GameText.by_lang("en"), ru_gt
  end

  test "by_lang scope is case-insensitive" do
    en_gt = GameText.create!(@valid_attrs)

    assert_includes GameText.by_lang("EN"), en_gt
    assert_includes GameText.by_lang("en"), en_gt
  end

  test "for_game scope filters by game" do
    game2 = Game.create!(name: "Another Game", release_year: 2023)
    gt1 = GameText.create!(@valid_attrs)
    gt2 = GameText.create!(@valid_attrs.merge(game: game2, lang_code: "ru"))

    assert_includes GameText.for_game(@game.id), gt1
    assert_not_includes GameText.for_game(@game.id), gt2
  end

  # ============================================
  # Association
  # ============================================
  test "belongs_to game association" do
    gt = GameText.create!(@valid_attrs)
    assert_equal @game.id, gt.game_id
    assert_equal @game.name, gt.game.name
  end

  test "game_text is destroyed when game is destroyed" do
    gt = GameText.create!(@valid_attrs)
    @game.destroy
    assert_raises ActiveRecord::RecordNotFound do
      GameText.find(gt.id)
    end
  end
end
