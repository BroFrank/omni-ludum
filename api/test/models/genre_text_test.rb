require "test_helper"

class GenreTextTest < ActiveSupport::TestCase
  setup do
    @genre = Genre.create!(name: "RPG")
    @valid_attrs = {
      genre: @genre,
      lang_code: "en",
      description: "Test description"
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates genre_text with valid attributes" do
    gt = GenreText.new(@valid_attrs)
    assert gt.valid?
  end

  test "genre_id must be present" do
    gt = GenreText.new(@valid_attrs.merge(genre: nil))
    assert_not gt.valid?
    assert gt.errors.added?(:genre, :blank)
  end

  test "lang_code must be present" do
    gt = GenreText.new(@valid_attrs.merge(lang_code: nil))
    assert_not gt.valid?
    assert gt.errors.added?(:lang_code, :blank)
  end

  test "lang_code must be exactly 2 characters" do
    gt = GenreText.new(@valid_attrs.merge(lang_code: "e"))
    assert_not gt.valid?
    assert gt.errors[:lang_code].any?

    gt = GenreText.new(@valid_attrs.merge(lang_code: "eng"))
    assert_not gt.valid?
    assert gt.errors[:lang_code].any?
  end

  test "lang_code must be lowercase latin letters" do
    gt = GenreText.new(@valid_attrs.merge(lang_code: "e1"))
    assert_not gt.valid?
    assert gt.errors[:lang_code].any?

    gt = GenreText.new(@valid_attrs.merge(lang_code: "1n"))
    assert_not gt.valid?
    assert gt.errors[:lang_code].any?
  end

  test "description can be nil" do
    gt = GenreText.new(@valid_attrs.merge(description: nil))
    assert gt.valid?
  end

  test "description has maximum length of 10000 characters" do
    gt = GenreText.new(@valid_attrs.merge(description: "a" * 10001))
    assert_not gt.valid?
    assert gt.errors[:description].any?

    gt = GenreText.new(@valid_attrs.merge(description: "a" * 10000))
    assert gt.valid?
  end

  test "lang_code is unique per genre_id (case-insensitive)" do
    GenreText.create!(@valid_attrs)

    gt = GenreText.new(@valid_attrs)
    assert_not gt.valid?
    assert_includes gt.errors.full_messages, "Lang code has already been taken"
  end

  test "same lang_code is allowed for different genres" do
    genre2 = Genre.create!(name: "Action")
    GenreText.create!(@valid_attrs)
    gt = GenreText.new(@valid_attrs.merge(genre: genre2))
    assert gt.valid?
  end

  # ============================================
  # Lang code normalization
  # ============================================
  test "lang_code is normalized to lowercase" do
    gt = GenreText.create!(@valid_attrs.merge(lang_code: "EN"))
    assert_equal "en", gt.lang_code
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only texts for active genres" do
    active_genre = Genre.create!(name: "Active Genre")
    disabled_genre = Genre.create!(name: "Disabled Genre", is_disabled: true)

    active_gt = GenreText.create!(@valid_attrs.merge(genre: active_genre))
    disabled_gt = GenreText.create!(@valid_attrs.merge(genre: disabled_genre, lang_code: "ru"))

    assert_includes GenreText.active, active_gt
    assert_not_includes GenreText.active, disabled_gt
  end

  test "by_lang scope filters by language" do
    en_gt = GenreText.create!(@valid_attrs)
    ru_gt = GenreText.create!(@valid_attrs.merge(lang_code: "ru"))

    assert_includes GenreText.by_lang("en"), en_gt
    assert_not_includes GenreText.by_lang("en"), ru_gt
  end

  test "by_lang scope is case-insensitive" do
    en_gt = GenreText.create!(@valid_attrs)

    assert_includes GenreText.by_lang("EN"), en_gt
    assert_includes GenreText.by_lang("en"), en_gt
  end

  test "for_genre scope filters by genre" do
    genre2 = Genre.create!(name: "Action")
    gt1 = GenreText.create!(@valid_attrs)
    gt2 = GenreText.create!(@valid_attrs.merge(genre: genre2, lang_code: "ru"))

    assert_includes GenreText.for_genre(@genre.id), gt1
    assert_not_includes GenreText.for_genre(@genre.id), gt2
  end

  # ============================================
  # Association
  # ============================================
  test "belongs_to genre association" do
    gt = GenreText.create!(@valid_attrs)
    assert_equal @genre.id, gt.genre_id
    assert_equal @genre.name, gt.genre.name
  end

  test "genre_text is destroyed when genre is destroyed" do
    gt = GenreText.create!(@valid_attrs)
    @genre.destroy
    assert_raises ActiveRecord::RecordNotFound do
      GenreText.find(gt.id)
    end
  end
end
