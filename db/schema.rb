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

ActiveRecord::Schema.define(version: 20140623150951) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fabrics", force: true do |t|
    t.numrange "price_eu"
    t.numrange "price_us"
    t.decimal  "weight",     precision: 8, scale: 2
    t.integer  "width"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", force: true do |t|
    t.integer  "kind",       default: 0
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "properties", ["kind"], name: "index_properties_on_kind", using: :btree
  add_index "properties", ["name"], name: "index_properties_on_name", using: :btree

  create_table "property_assignments", force: true do |t|
    t.integer  "property_id"
    t.integer  "fabric_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "property_assignments", ["fabric_id"], name: "index_property_assignments_on_fabric_id", using: :btree
  add_index "property_assignments", ["property_id"], name: "index_property_assignments_on_property_id", using: :btree

end
