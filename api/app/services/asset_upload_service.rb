class AssetUploadService
  MAX_FILE_SIZE = 10.megabytes
  ALLOWED_MIME_TYPES = %w[
    image/jpeg
    image/png
    image/webp
    application/pdf
  ].freeze

  class Error < StandardError; end
  class InvalidFileSizeError < Error; end
  class InvalidMimeTypeError < Error; end
  class UploadError < Error; end

  class << self
    def upload(game_id, file, asset_type, order_index: nil)
      game = Game.find(game_id)

      validate_file!(file)

      blob = ActiveStorage::Blob.create_and_upload!(
        io: file,
        filename: file.original_filename,
        content_type: file.content_type
      )

      asset = Asset.create!(
        game: game,
        asset_type: asset_type,
        storage_path: blob.key,
        mime_type: blob.content_type,
        file_size: blob.byte_size,
        order_index: order_index
      )

      asset
    rescue ActiveRecord::RecordNotFound => e
      raise Error, "Game not found: #{e.message}"
    rescue ActiveRecord::RecordInvalid => e
      raise UploadError, e.message
    end

    def remove(asset_id)
      asset = Asset.find(asset_id)

      blob = ActiveStorage::Blob.find_by(key: asset.storage_path)
      blob&.purge

      asset.disable!
    rescue ActiveRecord::RecordNotFound => e
      raise Error, "Asset not found: #{e.message}"
    end

    def replace(asset_id, new_file)
      asset = Asset.find(asset_id)

      validate_file!(new_file)

      old_blob = ActiveStorage::Blob.find_by(key: asset.storage_path)
      old_blob&.purge

      new_blob = ActiveStorage::Blob.create_and_upload!(
        io: new_file,
        filename: new_file.original_filename,
        content_type: new_file.content_type
      )

      asset.update!(
        storage_path: new_blob.key,
        mime_type: new_blob.content_type,
        file_size: new_blob.byte_size
      )

      asset
    rescue ActiveRecord::RecordNotFound => e
      raise Error, "Asset not found: #{e.message}"
    rescue ActiveRecord::RecordInvalid => e
      raise UploadError, e.message
    end

    def download_url(asset_id, expires_in: 5.minutes)
      asset = Asset.find(asset_id)
      blob = ActiveStorage::Blob.find_by(key: asset.storage_path)

      return nil unless blob

      Rails.application.routes.url_helpers.rails_blob_url(blob, expires_in: expires_in, only_path: true)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    private

    def validate_file!(file)
      validate_file_size!(file)
      validate_mime_type!(file)
    end

    def validate_file_size!(file)
      return unless file.size > MAX_FILE_SIZE

      raise InvalidFileSizeError, "File size must be less than #{MAX_FILE_SIZE / 1.megabyte} MB"
    end

    def validate_mime_type!(file)
      content_type = file.content_type

      return if ALLOWED_MIME_TYPES.include?(content_type)

      raise InvalidMimeTypeError, "File type #{content_type} is not allowed. Allowed types: #{ALLOWED_MIME_TYPES.join(', ')}"
    end
  end
end
