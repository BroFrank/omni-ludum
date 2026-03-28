json.extract! game, :id, :name, :release_year, :rating_avg, :difficulty_avg, :playtime_avg, :playtime_100_avg, :is_dlc, :is_mod, :is_disabled, :base_game_id, :platform_id, :publisher_id, :created_at, :updated_at
json.platform game.platform if game.platform
json.publisher game.publisher if game.publisher
json.genres game.genres.active do |genre|
  json.partial! "api/v1/genres/genre", genre: genre
end
