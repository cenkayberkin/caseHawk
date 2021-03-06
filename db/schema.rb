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
# It's strongly recommended to check this file into your version control system.


ActiveRecord::Schema.define(:version => 20130410041035) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_domain"
    t.datetime "deleted_at"
    t.text     "contact_roles"
    t.text     "roles"
    t.text     "case_statuses"
  end

  add_index "accounts", ["full_domain"], :name => "index_accounts_on_full_domain"

  create_table "addresses", :force => true do |t|
    t.string   "label"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "street"
    t.string   "unit"
    t.string   "city",             :limit => 50
    t.string   "postal_code",      :limit => 10
    t.string   "state",            :limit => 50
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "appointments", :force => true do |t|
    t.integer  "creator_id",   :null => false
    t.integer  "owner_id"
    t.integer  "account_id"
    t.integer  "location_id"
    t.string   "type",         :null => false
    t.string   "name",         :null => false
    t.boolean  "remind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.datetime "starts_at"
    t.datetime "end_at"
    t.datetime "deleted_at"
    t.integer  "completed_by"
    t.integer  "version"
  end

  create_table "case_contacts", :force => true do |t|
    t.integer  "case_id"
    t.integer  "contact_id"
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cases", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "current_status"
    t.string   "referral"
    t.text     "referral_details"
    t.string   "legal_plan"
    t.text     "legal_plan_details"
    t.string   "important_date"
    t.text     "important_date_details"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "case_type"
  end

  create_table "contacts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "email_addresses", :force => true do |t|
    t.string   "email"
    t.string   "label"
    t.integer  "contact_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "case_contacts", :force => true do |t|
    t.integer  "case_id"
    t.integer  "contact_id"
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cases", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "current_status"
    t.string   "referral"
    t.text     "referral_details"
    t.string   "legal_plan"
    t.text     "legal_plan_details"
    t.string   "important_date"
    t.text     "important_date_details"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "case_type"
  end

  create_table "contacts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.text     "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "email_addresses", :force => true do |t|
    t.string   "email"
    t.string   "label"
    t.integer  "contact_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "event_versions", :force => true do |t|
    t.integer  "event_id"
    t.integer  "version"
    t.integer  "creator_id"
    t.integer  "owner_id"
    t.integer  "location_id"
    t.string   "name"
    t.boolean  "remind",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "completed_by"
    t.integer  "account_id"
    t.string   "versioned_type"
    t.datetime "deleted_at"
    t.string   "uri"
    t.text     "recurrance"
    t.string   "uid"
    t.integer  "modified_by_id"
  end

  create_table "events", :force => true do |t|
    t.integer  "creator_id",                        :null => false
    t.integer  "owner_id"
    t.integer  "location_id"
    t.string   "type",                              :null => false
    t.string   "name",                              :null => false
    t.boolean  "remind",         :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.datetime "completed_at"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "completed_by"
    t.integer  "account_id"
    t.integer  "version"
    t.datetime "deleted_at"
    t.string   "uri"
    t.text     "recurrance"
    t.string   "uid"
    t.integer  "modified_by_id"
  end

  create_table "locations", :force => true do |t|
    t.integer  "event_id"
    t.string   "name",       :limit => 50
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "note_template_categories", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "note_templates", :force => true do |t|
    t.integer  "note_template_category_id"
    t.string   "template"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "notes", :force => true do |t|
    t.integer  "case_id"
    t.text     "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  create_table "phone_numbers", :force => true do |t|
    t.string   "number"
    t.string   "label"
    t.integer  "contact_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "note_template_categories", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "note_templates", :force => true do |t|
    t.integer  "note_template_category_id"
    t.string   "template"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "notes", :force => true do |t|
    t.integer  "case_id"
    t.text     "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  create_table "phone_numbers", :force => true do |t|
    t.string   "number"
    t.string   "label"
    t.integer  "contact_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "recent_tags", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.integer  "count",      :default => 0, :null => false
    t.datetime "updated_at"
  end

  create_table "saas_admins", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "password_salt",                         :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_affiliates", :force => true do |t|
    t.string   "name"
    t.decimal  "rate",       :precision => 6, :scale => 4, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  add_index "subscription_affiliates", ["token"], :name => "index_subscription_affiliates_on_token"

  create_table "subscription_discounts", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.decimal  "amount",                 :precision => 6, :scale => 2, :default => 0.0
    t.boolean  "percent"
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "apply_to_setup",                                       :default => true
    t.boolean  "apply_to_recurring",                                   :default => true
    t.integer  "trial_period_extension",                               :default => 0
  end

  create_table "subscription_payments", :force => true do |t|
    t.integer  "subscription_id"
    t.decimal  "amount",                    :precision => 10, :scale => 2, :default => 0.0
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "setup"
    t.boolean  "misc"
    t.integer  "subscription_affiliate_id"
    t.decimal  "affiliate_amount",          :precision => 6,  :scale => 2, :default => 0.0
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
  end

  add_index "subscription_payments", ["subscriber_id", "subscriber_type"], :name => "index_payments_on_subscriber"
  add_index "subscription_payments", ["subscription_id"], :name => "index_subscription_payments_on_subscription_id"

  create_table "subscription_plans", :force => true do |t|
    t.string   "name"
    t.decimal  "amount",         :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "renewal_period",                                :default => 1
    t.decimal  "setup_amount",   :precision => 10, :scale => 2
    t.integer  "trial_period",                                  :default => 1
    t.integer  "user_limit"
  end

  create_table "subscriptions", :force => true do |t|
    t.decimal  "amount",                    :precision => 10, :scale => 2
    t.datetime "next_renewal_at"
    t.string   "card_number"
    t.string   "card_expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                                    :default => "trial"
    t.integer  "subscription_plan_id"
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
    t.integer  "renewal_period",                                           :default => 1
    t.string   "billing_id"
    t.integer  "subscription_discount_id"
    t.integer  "subscription_affiliate_id"
    t.integer  "user_limit"
  end

  add_index "subscriptions", ["subscriber_id", "subscriber_type"], :name => "index_subscriptions_on_subscriber"

  create_table "taggings", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "automated",     :default => false, :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email",                                   :null => false
    t.string   "encrypted_password",                      :null => false
    t.string   "password_salt",                           :null => false
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.string   "last_sign_in_ip"
    t.string   "current_sign_in_ip"
    t.integer  "account_id"
    t.boolean  "admin",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        :default => 0
    t.integer  "failed_attempts",      :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "active",               :default => true
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
