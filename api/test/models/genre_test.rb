require "test_helper"

class GenreTest < ActiveSupport::TestCase
  setup do
    @valid_genre_attrs = {
      name: "RPG"
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates genre with valid attributes" do
    genre = Genre.new(@valid_genre_attrs)
    assert genre.valid?
  end

  test "name must be present" do
    genre = Genre.new(@valid_genre_attrs.merge(name: nil))
    assert_not genre.valid?
    assert genre.errors.added?(:name, :blank)
  end

  test "name must be unique (case-insensitive)" do
    Genre.create!(@valid_genre_attrs)
    genre = Genre.new(@valid_genre_attrs.merge(name: "rpg"))
    assert_not genre.valid?
    assert genre.errors.added?(:name, :taken)
  end

  test "slug must be present" do
    genre = Genre.new(name: nil, slug: nil)
    assert_not genre.valid?
    assert genre.errors.added?(:slug, :blank)
  end

  test "slug must be unique (case-insensitive)" do
    Genre.create!(@valid_genre_attrs.merge(slug: "test-slug"))
    genre = Genre.new(@valid_genre_attrs.merge(name: "Action", slug: "TEST-SLUG"))
    assert_not genre.valid?
    assert genre.errors.added?(:slug, :taken)
  end

  # ============================================
  # Auto-generated slug
  # ============================================
  test "slug is auto-generated from name" do
    genre = Genre.create!(@valid_genre_attrs)
    assert_equal "rpg", genre.slug
  end

  test "slug generation handles spaces" do
    genre = Genre.create!(name: "Role Playing Game")
    assert_equal "role-playing-game", genre.slug
  end

  test "slug generation handles special characters" do
    genre = Genre.create!(name: "Hack & Slash")
    assert_equal "hack-slash", genre.slug
  end

  test "slug generation handles uppercase" do
    genre = Genre.create!(name: "ACTION RPG")
    assert_equal "action-rpg", genre.slug
  end

  test "custom slug is preserved" do
    genre = Genre.create!(@valid_genre_attrs.merge(slug: "custom-rpg"))
    assert_equal "custom-rpg", genre.slug
  end

  # ============================================
  # Boolean fields default values
  # ============================================
  test "is_disabled defaults to false" do
    genre = Genre.create!(@valid_genre_attrs)
    assert_equal false, genre.is_disabled
  end

  test "is_disabled can be set to true" do
    genre = Genre.create!(@valid_genre_attrs.merge(is_disabled: true))
    assert genre.is_disabled
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only active genres" do
    active_genre = Genre.create!(@valid_genre_attrs)
    disabled_genre = Genre.create!(@valid_genre_attrs.merge(name: "Action", is_disabled: true))

    assert_includes Genre.active, active_genre
    assert_not_includes Genre.active, disabled_genre
  end

  test "disabled scope returns only disabled genres" do
    active_genre = Genre.create!(@valid_genre_attrs)
    disabled_genre = Genre.create!(@valid_genre_attrs.merge(name: "Action", is_disabled: true))

    assert_includes Genre.disabled, disabled_genre
    assert_not_includes Genre.disabled, active_genre
  end

  # ============================================
  # Instance methods
  # ============================================
  test "disable! sets is_disabled to true" do
    genre = Genre.create!(@valid_genre_attrs)
    genre.disable!
    assert genre.is_disabled
  end

  test "restore! sets is_disabled to false" do
    genre = Genre.create!(@valid_genre_attrs.merge(is_disabled: true))
    genre.restore!
    assert_not genre.is_disabled
  end

  # ============================================
  # Class methods
  # ============================================
  test "find_by_slug! finds active genre by slug" do
    genre = Genre.create!(@valid_genre_attrs)
    found_genre = Genre.find_by_slug!("rpg")
    assert_equal genre.id, found_genre.id
  end

  test "find_by_slug! raises error for non-existent slug" do
    assert_raises ActiveRecord::RecordNotFound do
      Genre.find_by_slug!("nonexistent")
    end
  end

  test "find_by_slug! raises error for disabled genre" do
    Genre.create!(@valid_genre_attrs.merge(is_disabled: true))
    assert_raises ActiveRecord::RecordNotFound do
      Genre.find_by_slug!("rpg")
    end
  end

  test "find_by_slug finds active genre by slug" do
    genre = Genre.create!(@valid_genre_attrs)
    found_genre = Genre.find_by_slug("rpg")
    assert_equal genre.id, found_genre.id
  end

  test "find_by_slug returns nil for non-existent slug" do
    found_genre = Genre.find_by_slug("nonexistent")
    assert_nil found_genre
  end

  test "find_by_slug returns nil for disabled genre" do
    Genre.create!(@valid_genre_attrs.merge(is_disabled: true))
    found_genre = Genre.find_by_slug("rpg")
    assert_nil found_genre
  end

  # ============================================
  # Genre texts association
  # ============================================
  test "genre has many genre_texts" do
    genre = Genre.create!(@valid_genre_attrs)
    en_text = GenreText.create!(genre: genre, lang_code: "en", description: "English description")
    ru_text = GenreText.create!(genre: genre, lang_code: "ru", description: "Русское описание")

    assert_equal 2, genre.genre_texts.count
    assert_includes genre.genre_texts, en_text
    assert_includes genre.genre_texts, ru_text
  end

  test "genre_texts are destroyed when genre is destroyed" do
    genre = Genre.create!(@valid_genre_attrs)
    GenreText.create!(genre: genre, lang_code: "en", description: "Description")

    genre.destroy

    assert_equal 0, GenreText.count
  end

  test "description_for returns description for specified locale" do
    genre = Genre.create!(@valid_genre_attrs)
    GenreText.create!(genre: genre, lang_code: "en", description: "English description")
    GenreText.create!(genre: genre, lang_code: "ru", description: "Русское описание")

    assert_equal "English description", genre.description_for("en")
    assert_equal "Русское описание", genre.description_for("ru")
    assert_nil genre.description_for("fr")
  end

  test "description_for is case-insensitive" do
    genre = Genre.create!(@valid_genre_attrs)
    GenreText.create!(genre: genre, lang_code: "en", description: "English description")

    assert_equal "English description", genre.description_for("EN")
    assert_equal "English description", genre.description_for("en")
  end

  test "all_descriptions returns descriptions ordered by lang_code" do
    genre = Genre.create!(@valid_genre_attrs)
    GenreText.create!(genre: genre, lang_code: "ru", description: "Русское описание")
    GenreText.create!(genre: genre, lang_code: "en", description: "English description")

    descriptions = genre.all_descriptions.to_a

    assert_equal 2, descriptions.count
    assert_equal "en", descriptions.first.lang_code
    assert_equal "ru", descriptions.second.lang_code
  end

  # ============================================
  # Games association through game_genres
  # ============================================
  test "genre has many games through game_genres" do
    genre = Genre.create!(@valid_genre_attrs)
    game1 = Game.create!(name: "Game 1", release_year: 2020)
    game2 = Game.create!(name: "Game 2", release_year: 2021)
    GameGenre.create!(game: game1, genre: genre)
    GameGenre.create!(game: game2, genre: genre)

    assert_equal 2, genre.games.count
    assert_includes genre.games, game1
    assert_includes genre.games, game2
  end

  test "game_genres are destroyed when genre is destroyed" do
    genre = Genre.create!(@valid_genre_attrs)
    game = Game.create!(name: "Test Game", release_year: 2020)
    GameGenre.create!(game: game, genre: genre)

    genre.destroy

    assert_equal 0, GameGenre.count
  end
end
