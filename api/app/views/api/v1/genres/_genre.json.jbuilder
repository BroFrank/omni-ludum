json.extract! genre, :id, :name, :slug, :is_disabled, :created_at, :updated_at
json.descriptions genre.genre_texts do |gt|
  json.lang gt.lang_code
  json.description gt.description
end
