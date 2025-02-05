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

ActiveRecord::Schema[7.0].define(version: 2023_11_10_125519) do
  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "csv_files", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "filename"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_csv_files_on_user_id"
  end

  create_table "email_job_specs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "print_job_spec_id", null: false
    t.string "csv_entries"
    t.string "attachment_pattern"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "subject"
    t.text "body"
    t.string "bcc"
    t.string "cc"
    t.bigint "smtp_account_id"
    t.bigint "fixed_attachment_id"
    t.index ["fixed_attachment_id"], name: "index_email_job_specs_on_fixed_attachment_id"
    t.index ["print_job_spec_id"], name: "index_email_job_specs_on_print_job_spec_id"
    t.index ["smtp_account_id"], name: "index_email_job_specs_on_smtp_account_id"
  end

  create_table "email_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "email_job_spec_id", null: false
    t.bigint "execution_job_id"
    t.string "csv_entry"
    t.string "status"
    t.integer "retries_left"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_job_spec_id"], name: "index_email_jobs_on_email_job_spec_id"
  end

  create_table "email_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "last_sent"
    t.string "subject"
    t.integer "size"
    t.string "attachment_path"
    t.string "state"
    t.integer "retries"
    t.string "last_error"
    t.string "message_id"
    t.string "last_smtp_server"
    t.text "raw_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "print_job_spec_id"
    t.index ["user_id"], name: "index_email_logs_on_user_id"
  end

  create_table "fixed_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email_filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_fixed_attachments_on_user_id"
  end

  create_table "generated_files", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "print_job_spec_id", null: false
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["path"], name: "index_generated_files_on_path", unique: true
    t.index ["print_job_spec_id"], name: "index_generated_files_on_print_job_spec_id"
  end

  create_table "odt_files", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "filename"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "system", default: false
    t.index ["user_id"], name: "index_odt_files_on_user_id"
  end

  create_table "print_job_specs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "odt_file_id", null: false
    t.bigint "csv_file_id", null: false
    t.string "status"
    t.text "messages"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["csv_file_id"], name: "index_print_job_specs_on_csv_file_id"
    t.index ["odt_file_id"], name: "index_print_job_specs_on_odt_file_id"
    t.index ["user_id"], name: "index_print_job_specs_on_user_id"
  end

  create_table "print_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "print_job_spec_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "execution_job_id"
    t.index ["print_job_spec_id"], name: "index_print_jobs_on_print_job_spec_id"
  end

  create_table "self_generated_emails", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "self_service_print_job_spec_id", null: false
    t.text "values"
    t.string "recipient"
    t.string "attachment_path", limit: 500
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["self_service_print_job_spec_id"], name: "index_self_generated_emails_on_self_service_print_job_spec_id"
    t.index ["status"], name: "index_self_generated_emails_on_status"
  end

  create_table "self_service_generated_files", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "self_service_print_job_id", null: false
    t.string "path", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["path"], name: "index_self_service_generated_files_on_path"
    t.index ["self_service_print_job_id"], name: "index_self_service_generated_files_on_self_service_print_job_id"
    t.index ["status"], name: "index_self_service_generated_files_on_status"
  end

  create_table "self_service_print_job_specs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "print_job_spec_id", null: false
    t.string "title", null: false
    t.string "secret_url_part", comment: "Used to create a url to be given to clients"
    t.boolean "active", default: false, comment: "Whether accepting clients or not"
    t.text "field_names"
    t.boolean "validate_client_email", default: false, comment: "Whether to verify that the email exists into csv file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "smtp_account_id"
    t.boolean "send_email", default: true
    t.boolean "direct_download", default: true
    t.string "css", default: "default.css"
    t.string "banner", default: "banner.jpg"
    t.string "gdpr", default: "gdpr.html"
    t.index ["print_job_spec_id"], name: "index_self_service_print_job_specs_on_print_job_spec_id"
    t.index ["secret_url_part"], name: "index_self_service_print_job_specs_on_secret_url_part"
    t.index ["smtp_account_id"], name: "index_self_service_print_job_specs_on_smtp_account_id"
  end

  create_table "self_service_print_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "self_service_print_job_spec_id", null: false
    t.text "field_values"
    t.string "user_specific_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recipient"
    t.index ["self_service_print_job_spec_id"], name: "index_self_service_print_jobs_on_self_service_print_job_spec_id"
    t.index ["user_specific_page"], name: "index_self_service_print_jobs_on_user_specific_page"
  end

  create_table "smtp_accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "Owner of this entry"
    t.string "description"
    t.string "from"
    t.string "server"
    t.integer "port"
    t.string "username", limit: 500, comment: "Extra large for encrypted content"
    t.string "password", limit: 500, comment: "Extra large for encrypted content"
    t.string "type", comment: "STI (Single Table Inheritance for SmtpAccount and SystemSmtpAccount)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_smtp_accounts_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
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
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.bigint "smtp_account_id"
    t.boolean "activated", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["smtp_account_id"], name: "index_users_on_smtp_account_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "csv_files", "users"
  add_foreign_key "email_job_specs", "fixed_attachments"
  add_foreign_key "email_job_specs", "print_job_specs"
  add_foreign_key "email_job_specs", "smtp_accounts"
  add_foreign_key "email_jobs", "email_job_specs"
  add_foreign_key "email_logs", "users"
  add_foreign_key "fixed_attachments", "users"
  add_foreign_key "generated_files", "print_job_specs"
  add_foreign_key "odt_files", "users"
  add_foreign_key "print_job_specs", "csv_files"
  add_foreign_key "print_job_specs", "odt_files"
  add_foreign_key "print_job_specs", "users"
  add_foreign_key "print_jobs", "print_job_specs"
  add_foreign_key "self_generated_emails", "self_service_print_job_specs"
  add_foreign_key "self_service_generated_files", "self_service_print_jobs"
  add_foreign_key "self_service_print_job_specs", "print_job_specs"
  add_foreign_key "self_service_print_job_specs", "smtp_accounts"
  add_foreign_key "self_service_print_jobs", "self_service_print_job_specs"
  add_foreign_key "smtp_accounts", "users"
  add_foreign_key "users", "smtp_accounts"
end
