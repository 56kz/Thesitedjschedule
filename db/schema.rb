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

ActiveRecord::Schema[8.0].define(version: 2025_01_29_023202) do
  create_table "reservations", force: :cascade do |t|
    t.bigint "schedule_id"
    t.bigint "suscription_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "start_hour"
    t.date "reserve_date"
    t.string "room"
    t.index ["schedule_id"], name: "index_reservations_on_schedule_id"
    t.index ["suscription_id"], name: "index_reservations_on_suscription_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.date "day"
    t.integer "hour"
    t.bigint "room_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["room_id"], name: "index_schedules_on_room_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["reset_password_token"], name: "index_students_on_reset_password_token", unique: true
  end

  create_table "suscriptions", force: :cascade do |t|
    t.integer "name"
    t.boolean "status"
    t.integer "hours"
    t.string "observations"
    t.string "rooms"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "invoice_number"
    t.index ["user_id"], name: "index_suscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.integer "rol"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  add_foreign_key "reservations", "schedules"
  add_foreign_key "reservations", "suscriptions"
  add_foreign_key "schedules", "rooms"
  add_foreign_key "suscriptions", "users"
end
