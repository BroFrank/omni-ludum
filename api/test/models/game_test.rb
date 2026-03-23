require "test_helper"

class GameTest < ActiveSupport::TestCase
  setup do
    @valid_game_attrs = {
      name: "Test Game",
      release_year: 2020
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates game with valid attributes" do
    game = Game.new(@valid_game_attrs)
    assert game.valid?
  end

  test "name must be present" do
    game = Game.new(@valid_game_attrs.merge(name: nil))
    assert_not game.valid?
    assert game.errors.added?(:name, :blank)
  end

  test "name must be unique (case insensitive)" do
    Game.create!(@valid_game_attrs)
    game = Game.new(@valid_game_attrs.merge(name: "test game"))
    assert_not game.valid?
    assert game.errors[:name].any?
  end

  test "name with different case are considered the same" do
    Game.create!(@valid_game_attrs)
    game = Game.new(@valid_game_attrs.merge(name: "Test Game", release_year: 2021))
    assert_not game.valid?
    assert game.errors[:name].any?
  end

  # ============================================
  # Release year validations
  # ============================================
  test "release_year must be an integer" do
    game = Game.new(@valid_game_attrs.merge(release_year: 2020.5))
    assert_not game.valid?
    assert game.errors[:release_year].any?
  end

  test "release_year must be in valid range (1970-2100)" do
    game = Game.new(@valid_game_attrs.merge(release_year: 1960))
    assert_not game.valid?
    assert game.errors[:release_year].any?

    game = Game.new(@valid_game_attrs.merge(release_year: 2101))
    assert_not game.valid?
    assert game.errors[:release_year].any?
  end

  test "release_year can be nil" do
    game = Game.new(@valid_game_attrs.merge(release_year: nil))
    assert game.valid?
  end

  test "release_year accepts valid values" do
    [ 1970, 2000, 2020, 2100 ].each do |year|
      game = Game.new(@valid_game_attrs.merge(release_year: year))
      assert game.valid?, "Release year #{year} should be valid"
    end
  end

  # ============================================
  # Rating avg validations
  # ============================================
  test "rating_avg must be between 0 and 10" do
    game = Game.new(@valid_game_attrs.merge(rating_avg: -1))
    assert_not game.valid?
    assert game.errors[:rating_avg].any?

    game = Game.new(@valid_game_attrs.merge(rating_avg: 10.1))
    assert_not game.valid?
    assert game.errors[:rating_avg].any?
  end

  test "rating_avg can be nil" do
    game = Game.new(@valid_game_attrs.merge(rating_avg: nil))
    assert game.valid?
  end

  test "rating_avg accepts valid values" do
    [ 0, 5.5, 10 ].each do |rating|
      game = Game.new(@valid_game_attrs.merge(rating_avg: rating))
      assert game.valid?, "Rating avg #{rating} should be valid"
    end
  end

  # ============================================
  # Difficulty avg validations
  # ============================================
  test "difficulty_avg must be between 0 and 10" do
    game = Game.new(@valid_game_attrs.merge(difficulty_avg: -1))
    assert_not game.valid?
    assert game.errors[:difficulty_avg].any?

    game = Game.new(@valid_game_attrs.merge(difficulty_avg: 10.1))
    assert_not game.valid?
    assert game.errors[:difficulty_avg].any?
  end

  test "difficulty_avg can be nil" do
    game = Game.new(@valid_game_attrs.merge(difficulty_avg: nil))
    assert game.valid?
  end

  test "difficulty_avg accepts valid values" do
    [ 0, 5.5, 10 ].each do |difficulty|
      game = Game.new(@valid_game_attrs.merge(difficulty_avg: difficulty))
      assert game.valid?, "Difficulty avg #{difficulty} should be valid"
    end
  end

  # ============================================
  # Playtime avg validations
  # ============================================
  test "playtime_avg must be non-negative" do
    game = Game.new(@valid_game_attrs.merge(playtime_avg: -1))
    assert_not game.valid?
    assert game.errors[:playtime_avg].any?
  end

  test "playtime_avg can be nil" do
    game = Game.new(@valid_game_attrs.merge(playtime_avg: nil))
    assert game.valid?
  end

  test "playtime_avg accepts valid values" do
    [ 0, 60, 120, 300 ].each do |playtime|
      game = Game.new(@valid_game_attrs.merge(playtime_avg: playtime))
      assert game.valid?, "Playtime avg #{playtime} should be valid"
    end
  end

  # ============================================
  # Playtime 100 avg validations
  # ============================================
  test "playtime_100_avg must be non-negative" do
    game = Game.new(@valid_game_attrs.merge(playtime_100_avg: -1))
    assert_not game.valid?
    assert game.errors[:playtime_100_avg].any?
  end

  test "playtime_100_avg can be nil" do
    game = Game.new(@valid_game_attrs.merge(playtime_100_avg: nil))
    assert game.valid?
  end

  test "playtime_100_avg accepts valid values" do
    [ 0, 120, 360, 600 ].each do |playtime|
      game = Game.new(@valid_game_attrs.merge(playtime_100_avg: playtime))
      assert game.valid?, "Playtime 100 avg #{playtime} should be valid"
    end
  end

  # ============================================
  # Boolean fields default values
  # ============================================
  test "is_dlc defaults to false" do
    game = Game.create!(@valid_game_attrs)
    assert_equal false, game.is_dlc
  end

  test "is_mod defaults to false" do
    game = Game.create!(@valid_game_attrs)
    assert_equal false, game.is_mod
  end

  test "is_disabled defaults to false" do
    game = Game.create!(@valid_game_attrs)
    assert_equal false, game.is_disabled
  end

  test "is_dlc can be set to true" do
    game = Game.create!(@valid_game_attrs.merge(is_dlc: true))
    assert game.is_dlc
  end

  test "is_mod can be set to true" do
    game = Game.create!(@valid_game_attrs.merge(is_mod: true))
    assert game.is_mod
  end

  test "is_disabled can be set to true" do
    game = Game.create!(@valid_game_attrs.merge(is_disabled: true))
    assert game.is_disabled
  end

  # ============================================
  # Base game association (self-reference)
  # ============================================
  test "game can have a base_game" do
    base_game = Game.create!(@valid_game_attrs)
    dlc = Game.create!(name: "DLC Pack", release_year: 2021, base_game_id: base_game.id)

    assert_equal base_game.id, dlc.base_game_id
    assert_equal base_game.id, dlc.base_game.id
  end

  test "game can have base_game_id nil" do
    game = Game.create!(@valid_game_attrs)
    assert_nil game.base_game_id
  end

  test "base_game method returns self if no base_game_id" do
    game = Game.create!(@valid_game_attrs)
    assert_equal game.id, game.base_game.id
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only active games" do
    active_game = Game.create!(@valid_game_attrs)
    disabled_game = Game.create!(@valid_game_attrs.merge(name: "Disabled Game", is_disabled: true))

    assert_includes Game.active, active_game
    assert_not_includes Game.active, disabled_game
  end

  test "disabled scope returns only disabled games" do
    active_game = Game.create!(@valid_game_attrs)
    disabled_game = Game.create!(@valid_game_attrs.merge(name: "Disabled Game", is_disabled: true))

    assert_includes Game.disabled, disabled_game
    assert_not_includes Game.disabled, active_game
  end

  test "with_base_game scope returns games with base_game_id" do
    base_game = Game.create!(@valid_game_attrs)
    dlc = Game.create!(name: "DLC Pack", release_year: 2021, base_game_id: base_game.id)
    original = Game.create!(@valid_game_attrs.merge(name: "Original Game"))

    assert_includes Game.with_base_game, dlc
    assert_not_includes Game.with_base_game, original
  end

  test "without_base_game scope returns games without base_game_id" do
    base_game = Game.create!(@valid_game_attrs)
    dlc = Game.create!(name: "DLC Pack", release_year: 2021, base_game_id: base_game.id)
    original = Game.create!(@valid_game_attrs.merge(name: "Original Game"))

    assert_includes Game.without_base_game, original
    assert_not_includes Game.without_base_game, dlc
  end

  test "dlcs scope returns only dlc games" do
    dlc = Game.create!(@valid_game_attrs.merge(name: "DLC Pack", is_dlc: true))
    mod = Game.create!(@valid_game_attrs.merge(name: "Mod Pack", is_mod: true))
    original = Game.create!(@valid_game_attrs.merge(name: "Original Game"))

    assert_includes Game.dlcs, dlc
    assert_not_includes Game.dlcs, mod
    assert_not_includes Game.dlcs, original
  end

  test "mods scope returns only mod games" do
    dlc = Game.create!(@valid_game_attrs.merge(name: "DLC Pack", is_dlc: true))
    mod = Game.create!(@valid_game_attrs.merge(name: "Mod Pack", is_mod: true))
    original = Game.create!(@valid_game_attrs.merge(name: "Original Game"))

    assert_includes Game.mods, mod
    assert_not_includes Game.mods, dlc
    assert_not_includes Game.mods, original
  end

  test "original_games scope returns only original games" do
    dlc = Game.create!(@valid_game_attrs.merge(name: "DLC Pack", is_dlc: true))
    mod = Game.create!(@valid_game_attrs.merge(name: "Mod Pack", is_mod: true))
    original = Game.create!(@valid_game_attrs.merge(name: "Original Game"))

    assert_includes Game.original_games, original
    assert_not_includes Game.original_games, dlc
    assert_not_includes Game.original_games, mod
  end

  # ============================================
  # Instance methods
  # ============================================
  test "dlc? returns true for dlc games" do
    dlc = Game.create!(@valid_game_attrs.merge(is_dlc: true))
    assert dlc.dlc?
  end

  test "dlc? returns false for non-dlc games" do
    original = Game.create!(@valid_game_attrs)
    assert_not original.dlc?
  end

  test "mod? returns true for mod games" do
    mod = Game.create!(@valid_game_attrs.merge(is_mod: true))
    assert mod.mod?
  end

  test "mod? returns false for non-mod games" do
    original = Game.create!(@valid_game_attrs)
    assert_not original.mod?
  end

  test "original_game? returns true for original games" do
    original = Game.create!(@valid_game_attrs)
    assert original.original_game?
  end

  test "original_game? returns false for dlc games" do
    dlc = Game.create!(@valid_game_attrs.merge(is_dlc: true))
    assert_not dlc.original_game?
  end

  test "original_game? returns false for mod games" do
    mod = Game.create!(@valid_game_attrs.merge(is_mod: true))
    assert_not mod.original_game?
  end

  # ============================================
  # Class methods
  # ============================================
  test "find_by_name! finds active game by name" do
    game = Game.create!(@valid_game_attrs)
    found_game = Game.find_by_name!("Test Game")
    assert_equal game.id, found_game.id
  end

  test "find_by_name! raises error for non-existent name" do
    assert_raises ActiveRecord::RecordNotFound do
      Game.find_by_name!("Nonexistent")
    end
  end

  test "find_by_name! raises error for disabled game" do
    Game.create!(@valid_game_attrs.merge(is_disabled: true))
    assert_raises ActiveRecord::RecordNotFound do
      Game.find_by_name!("Test Game")
    end
  end

  test "find_by_name finds active game by name" do
    game = Game.create!(@valid_game_attrs)
    found_game = Game.find_by_name("Test Game")
    assert_equal game.id, found_game.id
  end

  test "find_by_name returns nil for non-existent name" do
    found_game = Game.find_by_name("Nonexistent")
    assert_nil found_game
  end

  test "find_by_name returns nil for disabled game" do
    Game.create!(@valid_game_attrs.merge(is_disabled: true))
    found_game = Game.find_by_name("Test Game")
    assert_nil found_game
  end
end
