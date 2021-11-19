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

ActiveRecord::Schema.define(version: 2019_11_04_181458) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collections", id: :serial, force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "title"
    t.text "description"
    t.string "url"
    t.string "image_url"
    t.integer "vendor_id", default: 0, null: false
    t.string "vendor_identifier", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "project_uid", default: "", null: false
    t.index ["project_uid"], name: "index_collections_on_project_uid"
    t.index ["uid"], name: "index_collections_on_uid", unique: true
    t.index ["vendor_id"], name: "index_collections_on_vendor_id"
  end

  create_table "flag_types", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "label", default: "", null: false
    t.string "description", default: "", null: false
    t.string "category", default: "", null: false
    t.index ["category"], name: "index_flag_types_on_category"
    t.index ["name"], name: "index_flag_types_on_name", unique: true
  end

  create_table "flags", id: :serial, force: :cascade do |t|
    t.integer "transcript_id", default: 0, null: false
    t.integer "transcript_line_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.string "session_id", default: "", null: false
    t.integer "flag_type_id", default: 0, null: false
    t.string "text", default: "", null: false
    t.integer "is_deleted", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_resolved", default: 0, null: false
    t.index ["transcript_id"], name: "index_flags_on_transcript_id"
    t.index ["transcript_line_id"], name: "index_flags_on_transcript_line_id"
    t.index ["user_id"], name: "index_flags_on_user_id"
  end

  create_table "pg_search_documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "searchable_id"
    t.string "searchable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "speakers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transcript_edits", id: :serial, force: :cascade do |t|
    t.integer "transcript_id", default: 0, null: false
    t.integer "transcript_line_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.string "session_id", default: "", null: false
    t.string "text"
    t.integer "weight", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_deleted", default: 0, null: false
    t.index ["session_id", "transcript_line_id"], name: "index_transcript_edits_on_session_id_and_transcript_line_id", unique: true
    t.index ["session_id"], name: "index_transcript_edits_on_session_id"
    t.index ["transcript_id"], name: "index_transcript_edits_on_transcript_id"
    t.index ["transcript_line_id"], name: "index_transcript_edits_on_transcript_line_id"
    t.index ["user_id"], name: "index_transcript_edits_on_user_id"
  end

  create_table "transcript_line_statuses", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "progress", default: 0, null: false
    t.string "description"
    t.index ["name"], name: "index_transcript_line_statuses_on_name", unique: true
  end

  create_table "transcript_lines", id: :serial, force: :cascade do |t|
    t.integer "transcript_id", default: 0, null: false
    t.integer "start_time", default: 0, null: false
    t.integer "end_time", default: 0, null: false
    t.integer "speaker_id", default: 0, null: false
    t.string "original_text", default: "", null: false
    t.string "text", default: "", null: false
    t.integer "sequence", default: 0, null: false
    t.integer "transcript_line_status_id", default: 1, null: false
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "guess_text", default: "", null: false
    t.integer "flag_count", default: 0, null: false
    t.index ["speaker_id"], name: "index_transcript_lines_on_speaker_id"
    t.index ["transcript_id", "sequence"], name: "index_transcript_lines_on_transcript_id_and_sequence", unique: true
    t.index ["transcript_id"], name: "index_transcript_lines_on_transcript_id"
    t.index ["transcript_line_status_id"], name: "index_transcript_lines_on_transcript_line_status_id"
  end

  create_table "transcript_speaker_edits", id: :serial, force: :cascade do |t|
    t.integer "transcript_id", default: 0, null: false
    t.integer "transcript_line_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.string "session_id", default: "", null: false
    t.integer "speaker_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id", "transcript_line_id"], name: "index_transcript_speaker_edits_on_session_id_and_line_id", unique: true
    t.index ["transcript_line_id"], name: "index_transcript_speaker_edits_on_transcript_line_id"
    t.index ["user_id"], name: "index_transcript_speaker_edits_on_user_id"
  end

  create_table "transcript_speakers", id: :serial, force: :cascade do |t|
    t.integer "speaker_id", default: 0, null: false
    t.integer "transcript_id", default: 0, null: false
    t.integer "collection_id", default: 0, null: false
    t.string "project_uid", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["speaker_id", "transcript_id"], name: "index_transcript_speakers_on_speaker_id_and_transcript_id", unique: true
  end

  create_table "transcript_statuses", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "progress", default: 0, null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_transcript_statuses_on_name", unique: true
  end

  create_table "transcripts", id: :serial, force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "title"
    t.text "description"
    t.string "url"
    t.string "audio_url"
    t.string "image_url"
    t.integer "collection_id", default: 0, null: false
    t.integer "vendor_id", default: 0, null: false
    t.string "vendor_identifier", default: "", null: false
    t.integer "duration", default: 0, null: false
    t.integer "lines", default: 0, null: false
    t.text "notes"
    t.integer "transcript_status_id", default: 1, null: false
    t.integer "order", default: 0, null: false
    t.integer "created_by", default: 0, null: false
    t.string "batch_id", default: "unknown", null: false
    t.datetime "transcript_retrieved_at"
    t.datetime "transcript_processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "vendor_audio_urls", default: [], null: false
    t.string "project_uid", default: "", null: false
    t.integer "percent_completed", default: 0, null: false
    t.integer "lines_completed", default: 0, null: false
    t.integer "percent_edited", default: 0, null: false
    t.integer "lines_edited", default: 0, null: false
    t.integer "is_published", default: 1, null: false
    t.integer "percent_reviewing", default: 0, null: false
    t.integer "lines_reviewing", default: 0, null: false
    t.integer "users_contributed", default: 0, null: false
    t.integer "can_download", default: 1, null: false
    t.boolean "released", default: false
    t.index ["collection_id"], name: "index_transcripts_on_collection_id"
    t.index ["duration"], name: "index_transcripts_on_duration"
    t.index ["project_uid"], name: "index_transcripts_on_project_uid"
    t.index ["transcript_status_id"], name: "index_transcripts_on_transcript_status_id"
    t.index ["uid"], name: "index_transcripts_on_uid", unique: true
    t.index ["vendor_id"], name: "index_transcripts_on_vendor_id"
  end

  create_table "user_roles", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "hiearchy", default: 0, null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_user_roles_on_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_role_id", default: 0, null: false
    t.integer "lines_edited", default: 0, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "vendors", id: :serial, force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "name"
    t.string "description"
    t.string "url"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_vendors_on_uid", unique: true
  end

end
