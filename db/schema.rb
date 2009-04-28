# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090421222039) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_domain"
    t.datetime "deleted_at"
    t.integer  "subscription_discount_id", :limit => 8
  end

  create_table "addresses", :force => true do |t|
    t.string   "label"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "street"
    t.string   "unit"
    t.string   "city",             :limit => 50
    t.string   "postal_code",      :limit => 10
    t.string   "state",            :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bj_config", :primary_key => "bj_config_id", :force => true do |t|
    t.string "hostname"
    t.string "key"
    t.text   "value"
    t.text   "cast"
  end

  add_index "bj_config", ["hostname", "key"], :name => "index_bj_config_on_hostname_and_key", :unique => true

  create_table "bj_job", :primary_key => "bj_job_id", :force => true do |t|
    t.text     "command"
    t.text     "state"
    t.integer  "priority",       :limit => 8
    t.text     "tag"
    t.integer  "is_restartable", :limit => 8
    t.text     "submitter"
    t.text     "runner"
    t.integer  "pid",            :limit => 8
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "env"
    t.text     "stdin"
    t.text     "stdout"
    t.text     "stderr"
    t.integer  "exit_status",    :limit => 8
  end

  create_table "bj_job_archive", :primary_key => "bj_job_archive_id", :force => true do |t|
    t.text     "command"
    t.text     "state"
    t.integer  "priority",       :limit => 8
    t.text     "tag"
    t.integer  "is_restartable", :limit => 8
    t.text     "submitter"
    t.text     "runner"
    t.integer  "pid",            :limit => 8
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.text     "env"
    t.text     "stdin"
    t.text     "stdout"
    t.text     "stderr"
    t.integer  "exit_status",    :limit => 8
  end

  create_table "events", :force => true do |t|
    t.integer  "creator_id",                    :null => false
    t.integer  "owner_id"
    t.string   "kind",                          :null => false
    t.string   "name",                          :null => false
    t.date     "start_date"
    t.time     "start_time"
    t.date     "end_date"
    t.time     "end_time"
    t.boolean  "remind",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.integer  "event_id"
    t.string   "name",       :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_discounts", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.decimal  "amount",     :precision => 6, :scale => 2, :default => 0.0
    t.boolean  "percent"
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_payments", :force => true do |t|
    t.integer  "account_id",      :limit => 8
    t.integer  "subscription_id", :limit => 8
    t.decimal  "amount",                       :precision => 10, :scale => 2, :default => 0.0
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "setup"
  end

  create_table "subscription_plans", :force => true do |t|
    t.string   "name"
    t.decimal  "amount",                      :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_limit",     :limit => 8
    t.integer  "renewal_period", :limit => 8,                                :default => 1
    t.decimal  "setup_amount",                :precision => 10, :scale => 2
    t.integer  "trial_period",   :limit => 8,                                :default => 1
  end

  create_table "subscriptions", :force => true do |t|
    t.decimal  "amount",                            :precision => 10, :scale => 2
    t.datetime "next_renewal_at"
    t.string   "card_number"
    t.string   "card_expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                                            :default => "trial"
    t.integer  "subscription_plan_id", :limit => 8
    t.integer  "account_id",           :limit => 8
    t.integer  "user_limit",           :limit => 8
    t.integer  "renewal_period",       :limit => 8,                                :default => 1
    t.string   "billing_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "name"
    t.string   "remember_token"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "account_id",                :limit => 8
    t.boolean  "admin",                                   :default => false
  end

end
