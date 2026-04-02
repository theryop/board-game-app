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

ActiveRecord::Schema[8.1].define(version: 2026_04_02_072417) do
  create_table "games", force: :cascade do |t|
    t.string "bgg_url"
    t.integer "complexity"
    t.integer "condition"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "enjoyment"
    t.integer "max_players"
    t.integer "max_playtime"
    t.integer "min_players"
    t.integer "min_playtime"
    t.string "name"
    t.integer "times_played", default: 0, null: false
    t.datetime "updated_at", null: false
  end
end
