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

ActiveRecord::Schema.define(version: 20191104181458) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collections", force: :cascade do |t|
    t.string   "uid",               default: "", null: false
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.string   "image_url"
    t.integer  "vendor_id",         default: 0,  null: false
    t.string   "vendor_identifier", default: "", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "project_uid",       default: "", null: false
  end

  add_index "collections", ["project_uid"], name: "index_collections_on_project_uid", using: :btree
  add_index "collections", ["uid"], name: "index_collections_on_uid", unique: true, using: :btree
  add_index "collections", ["vendor_id"], name: "index_collections_on_vendor_id", using: :btree

  create_table "flag_types", force: :cascade do |t|
    t.string "name",        default: "", null: false
    t.string "label",       default: "", null: false
    t.string "description", default: "", null: false
    t.string "category",    default: "", null: false
  end

  add_index "flag_types", ["category"], name: "index_flag_types_on_category", using: :btree
  add_index "flag_types", ["name"], name: "index_flag_types_on_name", unique: true, using: :btree

  create_table "flags", force: :cascade do |t|
    t.integer  "transcript_id",      default: 0,  null: false
    t.integer  "transcript_line_id", default: 0,  null: false
    t.integer  "user_id",            default: 0,  null: false
    t.string   "session_id",         default: "", null: false
    t.integer  "flag_type_id",       default: 0,  null: false
    t.string   "text",               default: "", null: false
    t.integer  "is_deleted",         default: 0,  null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "is_resolved",        default: 0,  null: false
  end

  add_index "flags", ["transcript_id"], name: "index_flags_on_transcript_id", using: :btree
  add_index "flags", ["transcript_line_id"], name: "index_flags_on_transcript_line_id", using: :btree
  add_index "flags", ["user_id"], name: "index_flags_on_user_id", using: :btree

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "speakers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transcript_edits", force: :cascade do |t|
    t.integer  "transcript_id",      default: 0,  null: false
    t.integer  "transcript_line_id", default: 0,  null: false
    t.integer  "user_id",            default: 0,  null: false
    t.string   "session_id",         default: "", null: false
    t.string   "text"
    t.integer  "weight",             default: 0,  null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "is_deleted",         default: 0,  null: false
  end

  add_index "transcript_edits", ["session_id", "transcript_line_id"], name: "index_transcript_edits_on_session_id_and_transcript_line_id", unique: true, using: :btree
  add_index "transcript_edits", ["session_id"], name: "index_transcript_edits_on_session_id", using: :btree
  add_index "transcript_edits", ["transcript_id"], name: "index_transcript_edits_on_transcript_id", using: :btree
  add_index "transcript_edits", ["transcript_line_id"], name: "index_transcript_edits_on_transcript_line_id", using: :btree
  add_index "transcript_edits", ["user_id"], name: "index_transcript_edits_on_user_id", using: :btree

  create_table "transcript_line_statuses", force: :cascade do |t|
    t.string  "name",        default: "", null: false
    t.integer "progress",    default: 0,  null: false
    t.string  "description"
  end

  add_index "transcript_line_statuses", ["name"], name: "index_transcript_line_statuses_on_name", unique: true, using: :btree

  create_table "transcript_lines", force: :cascade do |t|
    t.integer  "transcript_id",             default: 0,  null: false
    t.integer  "start_time",                default: 0,  null: false
    t.integer  "end_time",                  default: 0,  null: false
    t.integer  "speaker_id",                default: 0,  null: false
    t.string   "original_text",             default: "", null: false
    t.string   "text",                      default: "", null: false
    t.integer  "sequence",                  default: 0,  null: false
    t.integer  "transcript_line_status_id", default: 1,  null: false
    t.string   "notes"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "guess_text",                default: "", null: false
    t.integer  "flag_count",                default: 0,  null: false
  end

  add_index "transcript_lines", ["speaker_id"], name: "index_transcript_lines_on_speaker_id", using: :btree
  add_index "transcript_lines", ["transcript_id", "sequence"], name: "index_transcript_lines_on_transcript_id_and_sequence", unique: true, using: :btree
  add_index "transcript_lines", ["transcript_id"], name: "index_transcript_lines_on_transcript_id", using: :btree
  add_index "transcript_lines", ["transcript_line_status_id"], name: "index_transcript_lines_on_transcript_line_status_id", using: :btree

  create_table "transcript_speaker_edits", force: :cascade do |t|
    t.integer  "transcript_id",      default: 0,  null: false
    t.integer  "transcript_line_id", default: 0,  null: false
    t.integer  "user_id",            default: 0,  null: false
    t.string   "session_id",         default: "", null: false
    t.integer  "speaker_id",         default: 0,  null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "transcript_speaker_edits", ["session_id", "transcript_line_id"], name: "index_transcript_speaker_edits_on_session_id_and_line_id", unique: true, using: :btree
  add_index "transcript_speaker_edits", ["transcript_line_id"], name: "index_transcript_speaker_edits_on_transcript_line_id", using: :btree
  add_index "transcript_speaker_edits", ["user_id"], name: "index_transcript_speaker_edits_on_user_id", using: :btree

  create_table "transcript_speakers", force: :cascade do |t|
    t.integer  "speaker_id",    default: 0,  null: false
    t.integer  "transcript_id", default: 0,  null: false
    t.integer  "collection_id", default: 0,  null: false
    t.string   "project_uid",   default: "", null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "transcript_speakers", ["speaker_id", "transcript_id"], name: "index_transcript_speakers_on_speaker_id_and_transcript_id", unique: true, using: :btree

  create_table "transcript_statuses", force: :cascade do |t|
    t.string   "name",        default: "", null: false
    t.integer  "progress",    default: 0,  null: false
    t.string   "description"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "transcript_statuses", ["name"], name: "index_transcript_statuses_on_name", unique: true, using: :btree

# Could not dump table "transcripts" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "user_roles", force: :cascade do |t|
    t.string   "name",        default: "", null: false
    t.integer  "hiearchy",    default: 0,  null: false
    t.string   "description"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "user_roles", ["name"], name: "index_user_roles_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_role_id",           default: 0,       null: false
    t.integer  "lines_edited",           default: 0,       null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "uid",         default: "", null: false
    t.string   "name"
    t.string   "description"
    t.string   "url"
    t.string   "image_url"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "vendors", ["uid"], name: "index_vendors_on_uid", unique: true, using: :btree

end
