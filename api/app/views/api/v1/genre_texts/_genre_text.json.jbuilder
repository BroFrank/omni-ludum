json.extract! genre_text, :id, :genre_id, :lang_code, :description, :created_at, :updated_at
json.genre do
  json.partial! "api/v1/genres/genre", genre: genre_text.genre
end
