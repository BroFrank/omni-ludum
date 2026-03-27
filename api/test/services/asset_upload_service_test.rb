require "test_helper"

class AssetUploadServiceTest < ActiveSupport::TestCase
  setup do
    @game = games(:one)
    @test_file = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/test_image.png"),
      "image/png"
    )
  end

  # ============================================
  # Upload tests
  # ============================================
  test "upload creates asset successfully" do
    asset = AssetUploadService.upload(@game.id, @test_file, "COVER")

    assert asset.present?
    assert_equal @game.id, asset.game_id
    assert_equal "COVER", asset.asset_type
    assert asset.storage_path.present?
    assert_equal "image/png", asset.mime_type
    assert asset.file_size > 0
  end

  test "upload creates asset with order_index" do
    asset = AssetUploadService.upload(@game.id, @test_file, "COVER", order_index: 5)

    assert_equal 5, asset.order_index
  end

  test "upload normalizes asset_type to uppercase" do
    asset = AssetUploadService.upload(@game.id, @test_file, "cover")

    assert_equal "COVER", asset.asset_type
  end

  test "upload raises error for non-existent game" do
    assert_raises AssetUploadService::Error do
      AssetUploadService.upload(999999, @test_file, "COVER")
    end
  end

  test "upload raises error for invalid mime type" do
    invalid_file = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/test_image.png"),
      "text/plain"
    )

    assert_raises AssetUploadService::InvalidMimeTypeError do
      AssetUploadService.upload(@game.id, invalid_file, "COVER")
    end
  end

  test "upload raises error for file too large" do
    large_file = Tempfile.new([ "large_file", ".png" ])
    large_file.binmode
    large_file.write("x" * (11.megabytes))
    large_file.rewind

    uploaded_file = Rack::Test::UploadedFile.new(large_file.path, "image/png")

    assert_raises AssetUploadService::InvalidFileSizeError do
      AssetUploadService.upload(@game.id, uploaded_file, "COVER")
    end

    large_file.close
    large_file.unlink
  end

  # ============================================
  # Remove tests
  # ============================================
  test "remove disables asset" do
    asset = Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: "assets/test.png",
      mime_type: "image/png",
      file_size: 1024
    )

    AssetUploadService.remove(asset.id)

    assert asset.reload.is_disabled
  end

  test "remove raises error for non-existent asset" do
    assert_raises AssetUploadService::Error do
      AssetUploadService.remove(999999)
    end
  end

  # ============================================
  # Replace tests
  # ============================================
  test "replace updates asset file" do
    asset = Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: "assets/old.png",
      mime_type: "image/png",
      file_size: 1024
    )

    new_file = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/test_image.png"),
      "image/png"
    )

    updated_asset = AssetUploadService.replace(asset.id, new_file)

    assert_equal asset.id, updated_asset.id
    assert_not_equal "assets/old.png", updated_asset.storage_path
  end

  test "replace raises error for non-existent asset" do
    assert_raises AssetUploadService::Error do
      AssetUploadService.replace(999999, @test_file)
    end
  end

  # ============================================
  # Download URL tests
  # ============================================
  test "download_url returns URL for valid asset" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: @test_file,
      filename: "test.png",
      content_type: "image/png"
    )
    asset = Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: blob.key,
      mime_type: "image/png",
      file_size: blob.byte_size
    )

    url = AssetUploadService.download_url(asset.id)

    assert url.present?
  end

  test "download_url returns nil for non-existent storage path" do
    asset = Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: "assets/nonexistent.png",
      mime_type: "image/png",
      file_size: 1024
    )

    url = AssetUploadService.download_url(asset.id)

    assert_nil url
  end

  test "download_url returns nil for non-existent asset" do
    url = AssetUploadService.download_url(999999)

    assert_nil url
  end

  test "download_url respects expires_in parameter" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: @test_file,
      filename: "test.png",
      content_type: "image/png"
    )
    asset = Asset.create!(
      game: @game,
      asset_type: "COVER",
      storage_path: blob.key,
      mime_type: "image/png",
      file_size: blob.byte_size
    )

    url = AssetUploadService.download_url(asset.id, expires_in: 1.hour)

    assert url.present?
  end
end
