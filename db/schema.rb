# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170123192821) do

  create_table "admin_users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "section"
    t.integer  "roll_number"
    t.integer  "year"
    t.string   "email"
    t.string   "username",                        null: false
    t.string   "password_digest"
    t.boolean  "superuser",       default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "lines", force: :cascade do |t|
    t.string   "address"
    t.string   "data",                    null: false
    t.string   "code",       default: "", null: false
    t.integer  "program_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["program_id"], name: "index_lines_on_program_id"
  end

  create_table "programs", force: :cascade do |t|
    t.integer  "position"
    t.string   "name",                           null: false
    t.text     "source",         default: ""
    t.text     "object_program", default: ""
    t.boolean  "visible",        default: false
    t.boolean  "addressing",     default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "tests", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "admin_user_id"
    t.integer  "score",         default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["admin_user_id"], name: "index_tests_on_admin_user_id"
    t.index ["program_id"], name: "index_tests_on_program_id"
  end

end
