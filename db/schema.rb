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

ActiveRecord::Schema.define(version: 20140714195641) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buyers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", using: :btree

  create_table "dye_methods", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dye_methods", ["name"], name: "index_dye_methods_on_name", using: :btree

  create_table "fabric_variants", force: true do |t|
    t.integer  "fabric_id"
    t.integer  "position"
    t.string   "fabrium_id"
    t.string   "item_number",  default: ""
    t.integer  "mill_id"
    t.string   "color"
    t.decimal  "cie_l",        default: 0.0
    t.decimal  "cie_a",        default: 0.0
    t.decimal  "cie_b",        default: 0.0
    t.string   "image_uid"
    t.string   "image_name"
    t.string   "image_crop"
    t.string   "image_width"
    t.string   "image_height"
    t.boolean  "in_stock",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fabric_variants", ["cie_l", "cie_a", "cie_b"], name: "by_cie_lab", using: :btree

  create_table "fabrics", force: true do |t|
    t.integer  "mill_id"
    t.integer  "dye_method_id"
    t.integer  "category_id"
    t.string   "item_number",                                    default: ""
    t.numrange "price_eu"
    t.numrange "price_us"
    t.integer  "width",                                          default: 0
    t.decimal  "gsm",                    precision: 8, scale: 2, default: 0.0
    t.decimal  "glm",                    precision: 8, scale: 2, default: 0.0
    t.decimal  "osy",                    precision: 8, scale: 2, default: 0.0
    t.string   "country",                                        default: ""
    t.integer  "sample_minimum_quality",                         default: 0
    t.integer  "bulk_minimum_quality",                           default: 0
    t.integer  "sample_lead_time",                               default: 0
    t.integer  "bulk_lead_time",                                 default: 0
    t.integer  "variant_index",                                  default: 0
    t.text     "tags",                                           default: [],  array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fabrics", ["category_id"], name: "index_fabrics_on_category_id", using: :btree
  add_index "fabrics", ["dye_method_id"], name: "index_fabrics_on_dye_method_id", using: :btree
  add_index "fabrics", ["glm"], name: "index_fabrics_on_glm", using: :btree
  add_index "fabrics", ["gsm"], name: "index_fabrics_on_gsm", using: :btree
  add_index "fabrics", ["mill_id"], name: "index_fabrics_on_mill_id", using: :btree
  add_index "fabrics", ["osy"], name: "index_fabrics_on_osy", using: :btree
  add_index "fabrics", ["price_eu"], name: "index_fabrics_on_price_eu", using: :gist
  add_index "fabrics", ["price_us"], name: "index_fabrics_on_price_us", using: :gist
  add_index "fabrics", ["tags"], name: "index_fabrics_on_tags", using: :gin

  create_table "material_assignments", force: true do |t|
    t.integer "material_id"
    t.integer "fabric_id"
    t.string  "value"
  end

  add_index "material_assignments", ["fabric_id"], name: "index_material_assignments_on_fabric_id", using: :btree
  add_index "material_assignments", ["material_id"], name: "index_material_assignments_on_material_id", using: :btree

  create_table "materials", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "materials", ["name"], name: "index_materials_on_name", using: :btree

  create_table "mills", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_assignments", force: true do |t|
    t.integer "tag_id"
    t.integer "fabric_id"
  end

  add_index "tag_assignments", ["fabric_id"], name: "index_tag_assignments_on_fabric_id", using: :btree
  add_index "tag_assignments", ["tag_id"], name: "index_tag_assignments_on_tag_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "users", force: true do |t|
    t.integer  "meta_id"
    t.string   "meta_type"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
