json.extract! game_text, :id, :game_id, :lang_code, :description, :trivia, :created_at, :updated_at
json.game do
  json.partial! "api/v1/games/game", game: game_text.game
end
