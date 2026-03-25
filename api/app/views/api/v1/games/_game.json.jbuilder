json.extract! game, :id, :name, :release_year, :rating_avg, :difficulty_avg, :playtime_avg, :playtime_100_avg, :is_dlc, :is_mod, :is_disabled, :base_game_id, :platform_id, :created_at, :updated_at
json.platform game.platform if game.platform
