json.extract! publisher_text, :id, :publisher_id, :lang_code, :description, :created_at, :updated_at
json.publisher do
  json.partial! "api/v1/publishers/publisher", publisher: publisher_text.publisher
end
