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

ActiveRecord::Schema[7.2].define(version: 2026_03_23_225409) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["base_game_id"], name: "index_games_on_base_game_id"
    t.index ["is_disabled"], name: "index_games_on_is_disabled"
    t.index ["name"], name: "index_games_on_name"
    t.index ["release_year"], name: "index_games_on_release_year"
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

  add_foreign_key "game_rating_recalculations", "games", on_delete: :cascade
  add_foreign_key "games", "games", column: "base_game_id"
  add_foreign_key "reviews", "games", on_delete: :cascade
  add_foreign_key "reviews", "users", on_delete: :cascade
end
