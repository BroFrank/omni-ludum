require "test_helper"

class GameGenreTest < ActiveSupport::TestCase
  setup do
    @game = Game.create!(name: "Test Game", release_year: 2024)
    @genre = Genre.create!(name: "RPG")
    @valid_attrs = {
      game: @game,
      genre: @genre
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates game_genre with valid attributes" do
    gg = GameGenre.new(@valid_attrs)
    assert gg.valid?
  end

  test "game_id must be present" do
    gg = GameGenre.new(@valid_attrs.merge(game: nil))
    assert_not gg.valid?
    assert gg.errors.added?(:game_id, :blank)
  end

  test "genre_id must be present" do
    gg = GameGenre.new(@valid_attrs.merge(genre: nil))
    assert_not gg.valid?
    assert gg.errors.added?(:genre_id, :blank)
  end

  test "game_id and genre_id combination must be unique for active records" do
    GameGenre.create!(@valid_attrs)

    gg = GameGenre.new(@valid_attrs)
    assert_not gg.valid?
    assert_includes gg.errors.full_messages, "Genre has already been taken"
  end

  test "same genre can be associated with different games" do
    game2 = Game.create!(name: "Another Game", release_year: 2023)
    GameGenre.create!(@valid_attrs)
    gg = GameGenre.new(@valid_attrs.merge(game: game2))
    assert gg.valid?
  end

  test "same game can have different genres" do
    genre2 = Genre.create!(name: "Action")
    GameGenre.create!(@valid_attrs)
    gg = GameGenre.new(@valid_attrs.merge(genre: genre2))
    assert gg.valid?
  end

  # ============================================
  # Boolean fields default values
  # ============================================
  test "is_disabled defaults to false" do
    gg = GameGenre.create!(@valid_attrs)
    assert_equal false, gg.is_disabled
  end

  test "is_disabled can be set to true" do
    gg = GameGenre.create!(@valid_attrs.merge(is_disabled: true))
    assert gg.is_disabled
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only active game genres" do
    game1 = Game.create!(name: "Game 1", release_year: 2024)
    game2 = Game.create!(name: "Game 1b", release_year: 2024)
    genre1 = Genre.create!(name: "RPG 1")
    active_gg = GameGenre.create!(game: game1, genre: genre1)
    disabled_gg = GameGenre.create!(game: game2, genre: genre1, is_disabled: true)

    assert_includes GameGenre.active, active_gg
    assert_not_includes GameGenre.active, disabled_gg
  end

  test "disabled scope returns only disabled game genres" do
    game1 = Game.create!(name: "Game 2", release_year: 2024)
    game2 = Game.create!(name: "Game 2b", release_year: 2024)
    genre1 = Genre.create!(name: "RPG 2")
    active_gg = GameGenre.create!(game: game1, genre: genre1)
    disabled_gg = GameGenre.create!(game: game2, genre: genre1, is_disabled: true)

    assert_includes GameGenre.disabled, disabled_gg
    assert_not_includes GameGenre.disabled, active_gg
  end

  # ============================================
  # Instance methods
  # ============================================
  test "disable! sets is_disabled to true" do
    game1 = Game.create!(name: "Game 3", release_year: 2024)
    genre1 = Genre.create!(name: "RPG 3")
    gg = GameGenre.create!(game: game1, genre: genre1)
    gg.disable!
    assert gg.is_disabled
  end

  test "restore! sets is_disabled to false" do
    game1 = Game.create!(name: "Game 4", release_year: 2024)
    genre1 = Genre.create!(name: "RPG 4")
    gg = GameGenre.create!(game: game1, genre: genre1, is_disabled: true)
    gg.restore!
    assert_not gg.is_disabled
  end

  # ============================================
  # Associations
  # ============================================
  test "belongs_to game association" do
    game1 = Game.create!(name: "Game 5", release_year: 2024)
    genre1 = Genre.create!(name: "RPG 5")
    gg = GameGenre.create!(game: game1, genre: genre1)
    assert_equal game1.id, gg.game_id
    assert_equal game1.name, gg.game.name
  end

  test "belongs_to genre association" do
    game1 = Game.create!(name: "Game 6", release_year: 2024)
    genre1 = Genre.create!(name: "RPG 6")
    gg = GameGenre.create!(game: game1, genre: genre1)
    assert_equal genre1.id, gg.genre_id
    assert_equal genre1.name, gg.genre.name
  end

  test "game is destroyed when game is destroyed" do
    game1 = Game.create!(name: "Game 7", release_year: 2024)
    genre1 = Genre.create!(name: "RPG 7")
    gg = GameGenre.create!(game: game1, genre: genre1)
    game1.destroy
    assert_raises ActiveRecord::RecordNotFound do
      GameGenre.find(gg.id)
    end
  end

  test "genre is destroyed when genre is destroyed" do
    game1 = Game.create!(name: "Game 8", release_year: 2024)
    genre1 = Genre.create!(name: "RPG 8")
    gg = GameGenre.create!(game: game1, genre: genre1)
    genre1.destroy
    assert_raises ActiveRecord::RecordNotFound do
      GameGenre.find(gg.id)
    end
  end
end
