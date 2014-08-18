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

ActiveRecord::Schema.define(version: 20140818205214) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approved_domains", force: true do |t|
    t.string   "name"
    t.integer  "entity",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buyer_mills", force: true do |t|
    t.integer  "mill_id"
    t.integer  "buyer_id"
    t.integer  "relationship", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "buyer_mills", ["buyer_id"], name: "index_buyer_mills_on_buyer_id", using: :btree
  add_index "buyer_mills", ["mill_id"], name: "index_buyer_mills_on_mill_id", using: :btree

  create_table "buyers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "position"
    t.string   "shipping_address_1"
    t.string   "shipping_address_2"
    t.string   "city"
    t.string   "subregion"
    t.string   "country"
    t.string   "phone"
    t.string   "postal_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cart_items", force: true do |t|
    t.integer  "fabric_variant_id"
    t.integer  "cart_id"
    t.integer  "mill_id"
    t.string   "fabrium_id"
    t.integer  "state",             default: 0
    t.text     "notes"
    t.decimal  "sample_yardage"
    t.boolean  "request_yardage",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["fabric_variant_id"], name: "index_cart_items_on_fabric_variant_id", using: :btree
  add_index "cart_items", ["mill_id"], name: "index_cart_items_on_mill_id", using: :btree

  create_table "carts", force: true do |t|
    t.integer  "mill_id"
    t.integer  "buyer_id"
    t.integer  "creator_id"
    t.string   "creator_type"
    t.integer  "parent_id"
    t.string   "buyer_email"
    t.string   "name"
    t.string   "public_id"
    t.string   "fabrium_id"
    t.integer  "state",           default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tracking_number"
  end

  add_index "carts", ["buyer_id"], name: "index_carts_on_buyer_id", using: :btree
  add_index "carts", ["mill_id"], name: "index_carts_on_mill_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dye_methods", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fabric_notes", force: true do |t|
    t.integer  "user_id"
    t.integer  "fabric_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fabric_variants", force: true do |t|
    t.integer  "fabric_id"
    t.integer  "position",     default: 0
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
  add_index "fabric_variants", ["fabric_id"], name: "index_fabric_variants_on_fabric_id", using: :btree

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
    t.text     "tags",                                           default: [],    array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "favorites_count",                                default: 0
    t.integer  "orders_count",                                   default: 0
    t.integer  "views_count",                                    default: 0
    t.boolean  "archived",                                       default: false
  end

  add_index "fabrics", ["category_id"], name: "index_fabrics_on_category_id", using: :btree
  add_index "fabrics", ["dye_method_id"], name: "index_fabrics_on_dye_method_id", using: :btree
  add_index "fabrics", ["mill_id"], name: "index_fabrics_on_mill_id", using: :btree
  add_index "fabrics", ["price_eu"], name: "index_fabrics_on_price_eu", using: :gist
  add_index "fabrics", ["price_us"], name: "index_fabrics_on_price_us", using: :gist
  add_index "fabrics", ["tags"], name: "index_fabrics_on_tags", using: :gin

  create_table "favorites", force: true do |t|
    t.integer  "user_id"
    t.integer  "fabric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["fabric_id"], name: "index_favorites_on_fabric_id", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

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

  create_table "mill_agents", force: true do |t|
    t.integer  "mill_id"
    t.string   "contact",    default: ""
    t.string   "email",      default: ""
    t.string   "phone",      default: ""
    t.string   "country",    default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mill_contacts", force: true do |t|
    t.integer  "mill_id"
    t.string   "kind",       default: ""
    t.string   "name",       default: ""
    t.string   "email",      default: ""
    t.string   "phone",      default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mill_references", force: true do |t|
    t.integer  "mill_id"
    t.string   "name",       default: ""
    t.string   "email",      default: ""
    t.string   "phone",      default: ""
    t.string   "company",    default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mills", force: true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.boolean  "active",                            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "domains",                           default: [],    array: true
    t.integer  "domain_filter",                     default: 0
    t.string   "shipping_address_1"
    t.string   "shipping_address_2"
    t.string   "city"
    t.string   "subregion"
    t.string   "country"
    t.string   "phone"
    t.string   "postal_code"
    t.string   "product_type"
    t.string   "monthly_total_capacity"
    t.string   "year_established"
    t.string   "number_of_employees"
    t.string   "major_markets"
    t.string   "major_customers"
    t.integer  "sample_minimum_quality",            default: 0
    t.integer  "bulk_minimum_quality",              default: 0
    t.integer  "sample_lead_time",                  default: 0
    t.integer  "bulk_lead_time",                    default: 0
    t.boolean  "seasonal",                          default: false
    t.integer  "seasonal_count",                    default: 0
    t.integer  "designs_per_season",                default: 0
    t.integer  "designs_in_archive",                default: 0
    t.integer  "spinning_monthly_capacity",         default: 0
    t.integer  "weaving_knitting_monthly_capacity", default: 0
    t.integer  "dying_monthly_capacity",            default: 0
    t.integer  "finishing_monthly_capacity",        default: 0
    t.integer  "printing_monthly_capacity",         default: 0
    t.integer  "printing_methods",                  default: 0
    t.integer  "printing_max_colors",               default: 0
    t.boolean  "automatic_lab_dipping",             default: false
    t.boolean  "spectrophotometer",                 default: false
    t.boolean  "light_box",                         default: false
    t.boolean  "internal_lab",                      default: false
    t.boolean  "light_sources",                     default: false
    t.string   "testing_capabilities"
    t.string   "inspection_stages"
    t.string   "inspection_system"
    t.integer  "years_attending_premiere_vision"
    t.integer  "years_attending_texworld"
  end

  add_index "mills", ["domains"], name: "index_mills_on_domains", using: :gin

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "meta_id"
    t.string   "meta_type"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.datetime "locked_at"
    t.boolean  "wants_email",            default: true
    t.boolean  "pending",                default: true
    t.boolean  "admin",                  default: false
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
  add_index "users", ["meta_id", "meta_type"], name: "index_users_on_meta_id_and_meta_type", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
