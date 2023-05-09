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

ActiveRecord::Schema[7.0].define(version: 2023_05_06_224029) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "subscription_billing_cycle", ["monthly", "yearly"]
  create_enum "subscription_status", ["payment_pending", "active", "inactive", "failed_to_activate"]

  create_table "access_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "last_used_on"
    t.string "token", null: false
    t.string "code"
    t.index ["code"], name: "index_access_tokens_on_code", unique: true
    t.index ["token"], name: "index_access_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_access_tokens_on_user_id"
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.integer "callback_priority"
    t.jsonb "serialized_properties"
    t.text "callback_queue_name"
    t.text "description"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "finished_at"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.text "error"
    t.text "job_class"
    t.text "queue_name"
    t.uuid "active_job_id", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.text "key"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "cron_at"
    t.datetime "finished_at"
    t.datetime "performed_at"
    t.datetime "scheduled_at"
    t.integer "executions_count"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.text "concurrency_key"
    t.text "cron_key"
    t.text "error"
    t.text "job_class"
    t.text "queue_name"
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.boolean "is_discrete"
    t.uuid "retried_good_job_id"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "site_id", null: false
    t.datetime "updated_at", null: false
    t.integer "monthly_price_cents", default: 0, null: false
    t.integer "yearly_price_cents", default: 0, null: false
    t.string "monthly_price_currency", default: "USD", null: false
    t.string "name", default: "", null: false
    t.string "stripe_monthly_price_id", default: "", null: false
    t.string "stripe_product_id", default: "", null: false
    t.string "stripe_yearly_price_id", default: "", null: false
    t.string "yearly_price_currency", default: "USD", null: false
    t.index ["site_id"], name: "index_plans_on_site_id"
  end

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "site_id", null: false
    t.datetime "updated_at", null: false
    t.text "content", null: false
    t.string "path", null: false
    t.string "title", default: "", null: false
    t.index ["site_id", "path"], name: "index_posts_on_site_id_and_path", unique: true
    t.index ["site_id"], name: "index_posts_on_site_id"
  end

  create_table "readers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_readers_on_user_id", unique: true
  end

  create_table "sites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "domain", null: false
    t.string "name", null: false
    t.string "public_token", null: false
    t.string "secret_token", null: false
    t.string "stripe_account_id", default: "", null: false
    t.boolean "charges_enabled", default: false, null: false
    t.boolean "details_submitted", default: false, null: false
    t.boolean "payouts_enabled", default: false, null: false
    t.index ["domain"], name: "index_sites_on_domain", unique: true
    t.index ["public_token"], name: "index_sites_on_public_token", unique: true
    t.index ["secret_token"], name: "index_sites_on_secret_token", unique: true
    t.index ["user_id"], name: "index_sites_on_user_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "plan_id", null: false
    t.bigint "reader_id", null: false
    t.bigint "site_id", null: false
    t.datetime "updated_at", null: false
    t.datetime "renews_on"
    t.datetime "starts_on"
    t.enum "billing_cycle", null: false, enum_type: "subscription_billing_cycle"
    t.enum "status", default: "payment_pending", null: false, enum_type: "subscription_status"
    t.string "stripe_customer_id", default: "", null: false
    t.string "stripe_subscription_id", default: "", null: false
    t.boolean "cancel_at_period_end", default: false, null: false
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["reader_id"], name: "index_subscriptions_on_reader_id"
    t.index ["site_id"], name: "index_subscriptions_on_site_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "confirmation_token"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "reset_password_token"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "access_tokens", "users"
  add_foreign_key "plans", "sites"
  add_foreign_key "posts", "sites"
  add_foreign_key "readers", "users"
  add_foreign_key "sites", "users"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "readers"
  add_foreign_key "subscriptions", "sites"
end
