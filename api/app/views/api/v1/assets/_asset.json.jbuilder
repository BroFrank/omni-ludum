json.extract! asset, :id, :game_id, :asset_type, :storage_path, :mime_type, :file_size, :order_index, :created_at, :updated_at
json.download_url download_api_v1_asset_url(asset)
