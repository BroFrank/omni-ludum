require "test_helper"

class AssetTest < ActiveSupport::TestCase
  setup do
    @game = games(:one)
    @valid_asset_attrs = {
      asset_type: "COVER",
      storage_path: "assets/test.png",
      mime_type: "image/png",
      file_size: 102400
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates asset with valid attributes" do
    asset = Asset.new(@valid_asset_attrs.merge(game: @game))
    assert asset.valid?
  end

  test "game_id must be present" do
    asset = Asset.new(@valid_asset_attrs.merge(game: nil))
    assert_not asset.valid?
    assert asset.errors.added?(:game, :blank)
  end

  test "asset_type must be present" do
    asset = Asset.new(@valid_asset_attrs.merge(asset_type: nil))
    assert_not asset.valid?
    assert asset.errors.added?(:asset_type, :blank)
  end

  test "asset_type must be a valid type" do
    asset = Asset.new(@valid_asset_attrs.merge(asset_type: "INVALID"))
    assert_not asset.valid?
    assert asset.errors[:asset_type].any?
  end

  test "asset_type accepts valid types" do
    [ "COVER", "SCREENSHOT", "MANUAL" ].each do |type|
      asset = Asset.new(@valid_asset_attrs.merge(asset_type: type, game: @game))
      assert asset.valid?, "Asset type #{type} should be valid"
    end
  end

  test "storage_path must be present" do
    asset = Asset.new(@valid_asset_attrs.merge(storage_path: nil))
    assert_not asset.valid?
    assert asset.errors.added?(:storage_path, :blank)
  end

  test "mime_type must be present" do
    asset = Asset.new(@valid_asset_attrs.merge(mime_type: nil))
    assert_not asset.valid?
    assert asset.errors.added?(:mime_type, :blank)
  end

  test "mime_type must be valid format" do
    asset = Asset.new(@valid_asset_attrs.merge(mime_type: "invalid"))
    assert_not asset.valid?
    assert asset.errors[:mime_type].any?
  end

  test "mime_type accepts valid formats" do
    [ "image/png", "image/jpeg", "image/webp", "application/pdf" ].each do |mime|
      asset = Asset.new(@valid_asset_attrs.merge(mime_type: mime, game: @game))
      assert asset.valid?, "MIME type #{mime} should be valid"
    end
  end

  test "file_size must be present" do
    asset = Asset.new(@valid_asset_attrs.merge(file_size: nil))
    assert_not asset.valid?
    assert asset.errors.added?(:file_size, :blank)
  end

  test "file_size must be positive" do
    asset = Asset.new(@valid_asset_attrs.merge(file_size: 0))
    assert_not asset.valid?
    assert asset.errors[:file_size].any?

    asset = Asset.new(@valid_asset_attrs.merge(file_size: -100))
    assert_not asset.valid?
    assert asset.errors[:file_size].any?
  end

  test "file_size accepts positive values" do
    [ 1, 1024, 1048576, 10485760 ].each do |size|
      asset = Asset.new(@valid_asset_attrs.merge(file_size: size, game: @game))
      assert asset.valid?, "File size #{size} should be valid"
    end
  end

  test "order_index can be nil" do
    asset = Asset.new(@valid_asset_attrs.merge(order_index: nil, game: @game))
    assert asset.valid?
  end

  test "order_index must be non-negative" do
    asset = Asset.new(@valid_asset_attrs.merge(order_index: -1, game: @game))
    assert_not asset.valid?
    assert asset.errors[:order_index].any?
  end

  test "order_index accepts zero and positive values" do
    [ 0, 1, 10, 100 ].each do |index|
      asset = Asset.new(@valid_asset_attrs.merge(order_index: index, game: @game))
      assert asset.valid?, "Order index #{index} should be valid"
    end
  end

  # ============================================
  # Asset type normalization
  # ============================================
  test "asset_type is normalized to uppercase" do
    asset = Asset.new(@valid_asset_attrs.merge(asset_type: "cover", game: @game))
    asset.valid?
    assert_equal "COVER", asset.asset_type
  end

  test "asset_type with mixed case is normalized" do
    asset = Asset.new(@valid_asset_attrs.merge(asset_type: "Screenshot", game: @game))
    asset.valid?
    assert_equal "SCREENSHOT", asset.asset_type
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only active assets" do
    active_asset = Asset.create!(@valid_asset_attrs.merge(game: @game))
    disabled_asset = Asset.create!(@valid_asset_attrs.merge(game: @game, storage_path: "assets/disabled.png", is_disabled: true))

    assert_includes Asset.active, active_asset
    assert_not_includes Asset.active, disabled_asset
  end

  test "disabled scope returns only disabled assets" do
    active_asset = Asset.create!(@valid_asset_attrs.merge(game: @game))
    disabled_asset = Asset.create!(@valid_asset_attrs.merge(game: @game, storage_path: "assets/disabled.png", is_disabled: true))

    assert_includes Asset.disabled, disabled_asset
    assert_not_includes Asset.disabled, active_asset
  end

  test "by_type scope returns assets with specified type" do
    cover = Asset.create!(@valid_asset_attrs.merge(game: @game))
    screenshot = Asset.create!(@valid_asset_attrs.merge(game: @game, asset_type: "SCREENSHOT", storage_path: "assets/screenshot.png"))

    assert_includes Asset.by_type("COVER"), cover
    assert_not_includes Asset.by_type("COVER"), screenshot
    assert_includes Asset.by_type("SCREENSHOT"), screenshot
  end

  test "ordered scope returns assets ordered by order_index" do
    Asset.delete_all
    asset3 = Asset.create!(@valid_asset_attrs.merge(game: @game, order_index: 2))
    asset1 = Asset.create!(@valid_asset_attrs.merge(game: @game, storage_path: "assets/first.png", order_index: 0))
    asset2 = Asset.create!(@valid_asset_attrs.merge(game: @game, storage_path: "assets/second.png", order_index: 1))

    ordered = Asset.ordered
    assert_equal [ asset1, asset2, asset3 ].map(&:id), ordered.map(&:id)
  end

  # ============================================
  # Instance methods
  # ============================================
  test "cover? returns true for COVER assets" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game))
    assert asset.cover?
  end

  test "cover? returns false for non-COVER assets" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game, asset_type: "SCREENSHOT", storage_path: "assets/screenshot.png"))
    assert_not asset.cover?
  end

  test "screenshot? returns true for SCREENSHOT assets" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game, asset_type: "SCREENSHOT", storage_path: "assets/screenshot.png"))
    assert asset.screenshot?
  end

  test "screenshot? returns false for non-SCREENSHOT assets" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game))
    assert_not asset.screenshot?
  end

  test "manual? returns true for MANUAL assets" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game, asset_type: "MANUAL", storage_path: "assets/manual.pdf", mime_type: "application/pdf"))
    assert asset.manual?
  end

  test "manual? returns false for non-MANUAL assets" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game))
    assert_not asset.manual?
  end

  test "type_label returns capitalized asset type" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game))
    assert_equal "Cover", asset.type_label
  end

  test "disable! sets is_disabled to true" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game))
    asset.disable!
    assert asset.reload.is_disabled
  end

  test "restore! sets is_disabled to false" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game, is_disabled: true))
    asset.restore!
    assert_not asset.reload.is_disabled
  end

  # ============================================
  # Association
  # ============================================
  test "asset belongs to game" do
    asset = Asset.create!(@valid_asset_attrs.merge(game: @game))
    assert_equal @game.id, asset.game.id
  end

  test "game has many assets" do
    Asset.delete_all
    Asset.create!(@valid_asset_attrs.merge(game: @game))
    Asset.create!(@valid_asset_attrs.merge(game: @game, asset_type: "SCREENSHOT", storage_path: "assets/screenshot.png"))

    assert_equal 2, @game.assets.count
  end

  test "assets are deleted when game is deleted" do
    game = Game.create!(name: "Temp Game", release_year: 2022)
    asset = Asset.create!(@valid_asset_attrs.merge(game: game))

    game.destroy
    assert_raises ActiveRecord::RecordNotFound do
      asset.reload
    end
  end
end
