# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150930132735) do

  create_table "boards", force: true do |t|
    t.integer  "width"
    t.integer  "height"
    t.integer  "spot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "board_image"
  end

  add_index "boards", ["spot_id"], name: "index_boards_on_spot_id"

  create_table "posts", force: true do |t|
    t.integer  "xcoord"
    t.integer  "ycoord"
    t.integer  "board_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "user_id"
  end

  add_index "posts", ["board_id"], name: "index_posts_on_board_id"
  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "spots", force: true do |t|
    t.decimal  "lat",        precision: 9, scale: 6
    t.decimal  "lon",        precision: 9, scale: 6
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
