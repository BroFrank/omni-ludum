# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_03_28_213526) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assets", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "asset_type", null: false
    t.string "storage_path", null: false
    t.string "mime_type", null: false
    t.integer "file_size", null: false
    t.integer "order_index"
    t.boolean "is_disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_type"], name: "index_assets_on_asset_type"
    t.index ["game_id", "asset_type"], name: "index_assets_on_game_id_and_asset_type"
    t.index ["game_id", "order_index"], name: "index_assets_on_game_id_and_order_index"
    t.index ["game_id"], name: "index_assets_on_game_id"
    t.index ["is_disabled"], name: "index_assets_on_is_disabled"
    t.check_constraint "asset_type::text = ANY (ARRAY['COVER'::character varying, 'SCREENSHOT'::character varying, 'MANUAL'::character varying]::text[])", name: "check_asset_type_valid"
    t.check_constraint "file_size > 0", name: "check_file_size_positive"
    t.check_constraint "order_index IS NULL OR order_index >= 0", name: "check_order_index_non_negative"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "table_name", null: false
    t.bigint "record_id", null: false
    t.string "action", null: false
    t.jsonb "old_values", default: {}
    t.jsonb "new_values", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["table_name", "record_id"], name: "index_audit_logs_on_table_and_record"
    t.index ["table_name"], name: "index_audit_logs_on_table_name"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
    t.check_constraint "action::text = ANY (ARRAY['CREATE'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying]::text[])", name: "check_audit_logs_action"
  end

  create_table "game_genres", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "genre_id", null: false
    t.boolean "is_disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "genre_id"], name: "index_game_genres_on_game_id_and_genre_id", unique: true
    t.index ["game_id"], name: "index_game_genres_on_game_id"
    t.index ["genre_id"], name: "index_game_genres_on_genre_id"
  end

  create_table "game_rating_recalculations", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "scheduled_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "processed_at"
    t.string "status", default: "pending", null: false
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "status"], name: "index_game_rating_recalculations_unique_pending", unique: true, where: "((status)::text = 'pending'::text)"
    t.index ["game_id"], name: "index_game_rating_recalculations_on_game_id"
    t.index ["scheduled_at"], name: "index_game_rating_recalculations_on_scheduled_at"
    t.index ["status"], name: "index_game_rating_recalculations_on_status"
  end

  create_table "game_texts", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "lang_code", limit: 2, null: false
    t.text "description"
    t.text "trivia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "lang_code"], name: "index_game_texts_on_game_id_and_lang_code", unique: true
    t.index ["game_id"], name: "index_game_texts_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.integer "release_year"
    t.float "rating_avg"
    t.float "difficulty_avg"
    t.integer "playtime_avg"
    t.integer "playtime_100_avg"
    t.boolean "is_dlc", default: false, null: false
    t.boolean "is_mod", default: false, null: false
    t.boolean "is_disabled", default: false, null: false
    t.bigint "base_game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "platform_id"
    t.bigint "publisher_id"
    t.index ["base_game_id"], name: "index_games_on_base_game_id"
    t.index ["is_disabled"], name: "index_games_on_is_disabled"
    t.index ["name"], name: "index_games_on_name"
    t.index ["platform_id"], name: "index_games_on_platform_id"
    t.index ["publisher_id"], name: "index_games_on_publisher_id"
    t.index ["release_year"], name: "index_games_on_release_year"
  end

  create_table "genre_texts", force: :cascade do |t|
    t.bigint "genre_id", null: false
    t.string "lang_code", limit: 2, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id", "lang_code"], name: "index_genre_texts_on_genre_id_and_lang_code", unique: true
    t.index ["genre_id"], name: "index_genre_texts_on_genre_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.boolean "is_disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_disabled"], name: "index_genres_on_is_disabled"
    t.index ["name"], name: "index_genres_on_name", unique: true
    t.index ["slug"], name: "index_genres_on_slug", unique: true
  end

  create_table "links", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "link_type", null: false
    t.text "url", null: false
    t.string "title", null: false
    t.boolean "is_disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "link_type"], name: "index_links_on_game_id_and_link_type"
    t.index ["game_id"], name: "index_links_on_game_id"
    t.index ["link_type"], name: "index_links_on_link_type"
    t.check_constraint "link_type::text = ANY (ARRAY['TRAILER'::character varying, 'LONGPLAY'::character varying, 'SPEEDRUN'::character varying, 'OTHER'::character varying]::text[])", name: "check_link_type_valid"
  end

  create_table "platforms", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.boolean "is_disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_disabled"], name: "index_platforms_on_is_disabled"
    t.index ["name"], name: "index_platforms_on_name"
    t.index ["slug"], name: "index_platforms_on_slug", unique: true
  end

  create_table "publisher_texts", force: :cascade do |t|
    t.bigint "publisher_id", null: false
    t.string "lang_code", limit: 2, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id", "lang_code"], name: "index_publisher_texts_on_publisher_id_and_lang_code", unique: true
    t.index ["publisher_id"], name: "index_publisher_texts_on_publisher_id"
  end

  create_table "publishers", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_disabled", default: false, null: false
    t.index ["is_disabled"], name: "index_publishers_on_is_disabled"
    t.index ["name"], name: "index_publishers_on_name", unique: true
    t.index ["slug"], name: "index_publishers_on_slug", unique: true
    t.index ["type"], name: "index_publishers_on_type"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_refresh_tokens_on_expires_at"
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest"
    t.index ["user_id", "expires_at"], name: "index_refresh_tokens_on_user_id_and_expires_at"
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.integer "rating", null: false
    t.integer "difficulty", null: false
    t.text "comment"
    t.boolean "is_disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "created_at"], name: "index_reviews_on_game_id_and_created_at"
    t.index ["game_id"], name: "index_reviews_on_game_id"
    t.index ["user_id", "created_at"], name: "index_reviews_on_user_id_and_created_at"
    t.index ["user_id", "game_id"], name: "index_reviews_on_user_id_and_game_id_unique", unique: true, where: "(is_disabled = false)"
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.check_constraint "difficulty >= 0 AND difficulty <= 10", name: "check_difficulty_range"
    t.check_constraint "rating >= 0 AND rating <= 10", name: "check_rating_range"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "REGULAR", null: false
    t.boolean "is_disabled", default: false, null: false
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme", default: "light", null: false
    t.string "locale", default: "en", null: false
    t.index "lower((username)::text)", name: "index_users_on_username_ci", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_disabled"], name: "index_users_on_is_disabled"
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_playtime_recalculations", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "scheduled_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "processed_at"
    t.string "status", default: "pending", null: false
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "status"], name: "index_users_playtime_recalculations_unique_pending", unique: true, where: "((status)::text = 'pending'::text)"
    t.index ["game_id"], name: "index_users_playtime_recalculations_on_game_id"
    t.index ["scheduled_at"], name: "index_users_playtime_recalculations_on_scheduled_at"
    t.index ["status"], name: "index_users_playtime_recalculations_on_status"
  end

  create_table "users_playtimes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.integer "minutes_regular"
    t.integer "minutes_100"
    t.boolean "is_disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "created_at"], name: "index_users_playtimes_on_game_id_and_created_at"
    t.index ["game_id"], name: "index_users_playtimes_on_game_id"
    t.index ["user_id", "created_at"], name: "index_users_playtimes_on_user_id_and_created_at"
    t.index ["user_id", "game_id"], name: "index_users_playtimes_on_user_id_and_game_id_unique", unique: true, where: "(is_disabled = false)"
    t.index ["user_id"], name: "index_users_playtimes_on_user_id"
    t.check_constraint "minutes_100 >= 0", name: "check_minutes_100_positive"
    t.check_constraint "minutes_regular >= 0", name: "check_minutes_regular_positive"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assets", "games", on_delete: :cascade
  add_foreign_key "audit_logs", "users", on_delete: :nullify
  add_foreign_key "game_genres", "games", on_delete: :cascade
  add_foreign_key "game_genres", "genres", on_delete: :cascade
  add_foreign_key "game_rating_recalculations", "games", on_delete: :cascade
  add_foreign_key "game_texts", "games", on_delete: :cascade
  add_foreign_key "games", "games", column: "base_game_id"
  add_foreign_key "games", "platforms"
  add_foreign_key "games", "publishers", on_delete: :nullify
  add_foreign_key "genre_texts", "genres", on_delete: :cascade
  add_foreign_key "links", "games", on_delete: :cascade
  add_foreign_key "publisher_texts", "publishers", on_delete: :cascade
  add_foreign_key "refresh_tokens", "users", on_delete: :cascade
  add_foreign_key "reviews", "games", on_delete: :cascade
  add_foreign_key "reviews", "users", on_delete: :cascade
  add_foreign_key "users_playtime_recalculations", "games", on_delete: :cascade
  add_foreign_key "users_playtimes", "games", on_delete: :cascade
  add_foreign_key "users_playtimes", "users", on_delete: :cascade
end
