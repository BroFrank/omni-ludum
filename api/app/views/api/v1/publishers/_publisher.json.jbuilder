json.extract! publisher, :id, :name, :type, :slug, :is_disabled, :created_at, :updated_at
json.games_count publisher.games.active.count
json.descriptions publisher.publisher_texts do |pt|
  json.lang pt.lang_code
  json.description pt.description
end
