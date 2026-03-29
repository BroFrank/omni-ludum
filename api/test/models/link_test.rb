require "test_helper"

class LinkTest < ActiveSupport::TestCase
  setup do
    @game = games(:one)
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates link with valid attributes" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Official Trailer"
    )
    assert link.save
  end

  test "should require game_id" do
    link = Link.new(
      game_id: nil,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Official Trailer"
    )
    assert_not link.valid?
    assert_includes link.errors[:game], "must exist"
  end

  test "should require link_type" do
    link = Link.new(
      game: @game,
      link_type: nil,
      url: "https://www.youtube.com/watch?v=example",
      title: "Official Trailer"
    )
    assert_not link.valid?
    assert_includes link.errors[:link_type], "can't be blank"
  end

  test "should require url" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: nil,
      title: "Official Trailer"
    )
    assert_not link.valid?
    assert_includes link.errors[:url], "can't be blank"
  end

  test "should require title" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: nil
    )
    assert_not link.valid?
    assert_includes link.errors[:title], "can't be blank"
  end

  # ============================================
  # Link type validations
  # ============================================
  test "link_type must be a valid type" do
    link = Link.new(
      game: @game,
      link_type: "INVALID_TYPE",
      url: "https://www.youtube.com/watch?v=example",
      title: "Official Trailer"
    )
    assert_not link.valid?
    assert_includes link.errors[:link_type], "must be a valid link type"
  end

  test "link_type accepts TRAILER" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Official Trailer"
    )
    assert link.valid?
  end

  test "link_type accepts LONGPLAY" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::LONGPLAY,
      url: "https://www.youtube.com/watch?v=example",
      title: "Full Longplay"
    )
    assert link.valid?
  end

  test "link_type accepts SPEEDRUN" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::SPEEDRUN,
      url: "https://www.youtube.com/watch?v=example",
      title: "Any% Speedrun"
    )
    assert link.valid?
  end

  test "link_type accepts OTHER" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::OTHER,
      url: "https://www.example.com/guide",
      title: "Strategy Guide"
    )
    assert link.valid?
  end

  test "link_type is normalized to uppercase" do
    link = Link.new(
      game: @game,
      link_type: "trailer",
      url: "https://www.youtube.com/watch?v=example",
      title: "Official Trailer"
    )
    assert link.valid?
    link.save
    assert_equal "TRAILER", link.link_type
  end

  # ============================================
  # URL validations
  # ============================================
  test "url must be valid format" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "not-a-url",
      title: "Official Trailer"
    )
    assert_not link.valid?
    assert_includes link.errors[:url], "must be a valid URL"
  end

  test "url accepts http URLs" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "http://www.example.com/video",
      title: "Official Trailer"
    )
    assert link.valid?
  end

  test "url accepts https URLs" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Official Trailer"
    )
    assert link.valid?
  end

  # ============================================
  # Title validations
  # ============================================
  test "title must not be empty" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: ""
    )
    assert_not link.valid?
    assert_includes link.errors[:title], "can't be blank"
  end

  test "title must not exceed 255 characters" do
    link = Link.new(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "a" * 256
    )
    assert_not link.valid?
    assert link.errors[:title].any? { |msg| msg.include?("too long") }
  end

  test "title accepts valid length strings" do
    [ "Short", "a" * 255 ].each do |title|
      link = Link.new(
        game: @game,
        link_type: LINK_TYPES::TRAILER,
        url: "https://www.youtube.com/watch?v=example",
        title: title
      )
      assert link.valid?, "Title '#{title}' should be valid"
    end
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only non-disabled links" do
    active_link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=active",
      title: "Active Link",
      is_disabled: false
    )

    disabled_link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=disabled",
      title: "Disabled Link",
      is_disabled: true
    )

    assert_includes Link.active, active_link
    assert_not_includes Link.active, disabled_link
  end

  test "disabled scope returns only disabled links" do
    active_link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=active",
      title: "Active Link",
      is_disabled: false
    )

    disabled_link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=disabled",
      title: "Disabled Link",
      is_disabled: true
    )

    assert_includes Link.disabled, disabled_link
    assert_not_includes Link.disabled, active_link
  end

  test "by_type scope filters by link type" do
    trailer = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=trailer",
      title: "Trailer"
    )

    longplay = Link.create!(
      game: @game,
      link_type: LINK_TYPES::LONGPLAY,
      url: "https://www.youtube.com/watch?v=longplay",
      title: "Longplay"
    )

    assert_includes Link.by_type(LINK_TYPES::TRAILER), trailer
    assert_not_includes Link.by_type(LINK_TYPES::TRAILER), longplay
    assert_includes Link.by_type(LINK_TYPES::LONGPLAY), longplay
    assert_not_includes Link.by_type(LINK_TYPES::LONGPLAY), trailer
  end

  # ============================================
  # Instance methods - type predicates
  # ============================================
  test "trailer? returns true for TRAILER type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer"
    )
    assert link.trailer?
  end

  test "trailer? returns false for non-TRAILER type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::LONGPLAY,
      url: "https://www.youtube.com/watch?v=example",
      title: "Longplay"
    )
    assert_not link.trailer?
  end

  test "longplay? returns true for LONGPLAY type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::LONGPLAY,
      url: "https://www.youtube.com/watch?v=example",
      title: "Longplay"
    )
    assert link.longplay?
  end

  test "longplay? returns false for non-LONGPLAY type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer"
    )
    assert_not link.longplay?
  end

  test "speedrun? returns true for SPEEDRUN type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::SPEEDRUN,
      url: "https://www.youtube.com/watch?v=example",
      title: "Speedrun"
    )
    assert link.speedrun?
  end

  test "speedrun? returns false for non-SPEEDRUN type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer"
    )
    assert_not link.speedrun?
  end

  test "other? returns true for OTHER type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::OTHER,
      url: "https://www.example.com/guide",
      title: "Guide"
    )
    assert link.other?
  end

  test "other? returns false for non-OTHER type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer"
    )
    assert_not link.other?
  end

  test "type_label returns capitalized link type" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer"
    )
    assert_equal "Trailer", link.type_label

    link.update!(link_type: LINK_TYPES::LONGPLAY)
    assert_equal "Longplay", link.type_label
  end

  # ============================================
  # Soft delete methods
  # ============================================
  test "disable! sets is_disabled to true" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer"
    )
    assert_not link.is_disabled

    link.disable!

    assert link.is_disabled
  end

  test "restore! sets is_disabled to false" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer",
      is_disabled: true
    )
    assert link.is_disabled

    link.restore!

    assert_not link.is_disabled
  end

  # ============================================
  # Association tests
  # ============================================
  test "should belong to game" do
    link = Link.create!(
      game: @game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer"
    )
    assert_equal @game, link.game
  end

  test "link is destroyed when game is destroyed (cascade)" do
    game = Game.create!(name: "Test Game for Deletion", release_year: 2020)
    link = Link.create!(
      game: game,
      link_type: LINK_TYPES::TRAILER,
      url: "https://www.youtube.com/watch?v=example",
      title: "Trailer"
    )

    assert_difference -> { Link.count }, -1 do
      game.destroy
    end
  end
end
