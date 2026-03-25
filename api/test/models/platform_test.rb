require "test_helper"

class PlatformTest < ActiveSupport::TestCase
  setup do
    @valid_platform_attrs = {
      name: "Test Platform",
      slug: "test-platform"
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates platform with valid attributes" do
    platform = Platform.new(@valid_platform_attrs)
    assert platform.valid?
  end

  test "name must be present" do
    platform = Platform.new(@valid_platform_attrs.merge(name: nil))
    assert_not platform.valid?
    assert platform.errors.added?(:name, :blank)
  end

  test "slug is auto-generated when blank" do
    platform = Platform.new(name: "Test Platform")
    assert platform.valid?
    assert_equal "test-platform", platform.slug
  end

  test "slug format validation rejects invalid characters" do
    platform = Platform.new(name: "Test", slug: "test@platform")
    assert_not platform.valid?
    assert platform.errors[:slug].any?
  end

  test "slug must be unique (case insensitive)" do
    Platform.create!(@valid_platform_attrs)
    platform = Platform.new(@valid_platform_attrs.merge(slug: "TEST-PLATFORM"))
    assert_not platform.valid?
    assert platform.errors[:slug].any?
  end

  test "slug accepts lowercase letters, numbers, hyphens, and underscores" do
    valid_slugs = [
      "pc",
      "playstation-5",
      "xbox_series_x",
      "nintendo-switch",
      "test-123",
      "test_abc_123"
    ]

    valid_slugs.each do |slug|
      platform = Platform.new(@valid_platform_attrs.merge(slug: slug))
      assert platform.valid?, "Slug '#{slug}' should be valid"
    end
  end

  test "slug rejects uppercase letters" do
    platform = Platform.new(@valid_platform_attrs.merge(slug: "Test-Platform"))
    assert_not platform.valid?
    assert platform.errors[:slug].any?
  end

  test "slug rejects special characters" do
    invalid_slugs = [
      "test platform",
      "test@platform",
      "test#platform",
      "test.platform",
      "test/platform"
    ]

    invalid_slugs.each do |slug|
      platform = Platform.new(@valid_platform_attrs.merge(slug: slug))
      assert_not platform.valid?, "Slug '#{slug}' should be invalid"
      assert platform.errors[:slug].any?
    end
  end

  # ============================================
  # Auto-generated slug
  # ============================================
  test "slug is auto-generated from name if not provided" do
    platform = Platform.new(name: "Nintendo Switch")
    platform.valid?
    assert_equal "nintendo-switch", platform.slug
  end

  test "slug auto-generation replaces spaces with hyphens" do
    platform = Platform.new(name: "PlayStation 5")
    platform.valid?
    assert_equal "playstation-5", platform.slug
  end

  test "slug auto-generation removes special characters" do
    platform = Platform.new(name: "Mobile (iOS)")
    platform.valid?
    assert_equal "mobile-ios", platform.slug
  end

  # ============================================
  # Boolean fields default values
  # ============================================
  test "is_disabled defaults to false" do
    platform = Platform.create!(@valid_platform_attrs)
    assert_equal false, platform.is_disabled
  end

  test "is_disabled can be set to true" do
    platform = Platform.create!(@valid_platform_attrs.merge(is_disabled: true))
    assert platform.is_disabled
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only active platforms" do
    active_platform = Platform.create!(@valid_platform_attrs)
    disabled_platform = Platform.create!(@valid_platform_attrs.merge(slug: "disabled", is_disabled: true))

    assert_includes Platform.active, active_platform
    assert_not_includes Platform.active, disabled_platform
  end

  test "disabled scope returns only disabled platforms" do
    active_platform = Platform.create!(@valid_platform_attrs)
    disabled_platform = Platform.create!(@valid_platform_attrs.merge(slug: "disabled", is_disabled: true))

    assert_includes Platform.disabled, disabled_platform
    assert_not_includes Platform.disabled, active_platform
  end

  # ============================================
  # Association with games
  # ============================================
  test "platform can have many games" do
    platform = Platform.create!(@valid_platform_attrs)
    game1 = Game.create!(name: "Game 1", release_year: 2020, platform: platform)
    game2 = Game.create!(name: "Game 2", release_year: 2021, platform: platform)

    assert_includes platform.games, game1
    assert_includes platform.games, game2
    assert_equal 2, platform.games.count
  end

  test "platform games are nullified when platform is deleted" do
    platform = Platform.create!(@valid_platform_attrs)
    game = Game.create!(name: "Test Game", release_year: 2020, platform: platform)

    platform.destroy

    game.reload
    assert_nil game.platform_id
  end

  # ============================================
  # Class methods
  # ============================================
  test "find_by_slug! finds active platform by slug" do
    platform = Platform.create!(@valid_platform_attrs)
    found_platform = Platform.find_by_slug!("test-platform")
    assert_equal platform.id, found_platform.id
  end

  test "find_by_slug! raises error for non-existent slug" do
    assert_raises ActiveRecord::RecordNotFound do
      Platform.find_by_slug!("nonexistent")
    end
  end

  test "find_by_slug! raises error for disabled platform" do
    Platform.create!(@valid_platform_attrs.merge(is_disabled: true))
    assert_raises ActiveRecord::RecordNotFound do
      Platform.find_by_slug!("test-platform")
    end
  end

  test "find_by_slug finds active platform by slug" do
    platform = Platform.create!(@valid_platform_attrs)
    found_platform = Platform.find_by_slug("test-platform")
    assert_equal platform.id, found_platform.id
  end

  test "find_by_slug returns nil for non-existent slug" do
    found_platform = Platform.find_by_slug("nonexistent")
    assert_nil found_platform
  end

  test "find_by_slug returns nil for disabled platform" do
    Platform.create!(@valid_platform_attrs.merge(is_disabled: true))
    found_platform = Platform.find_by_slug("test-platform")
    assert_nil found_platform
  end
end
