class AddUser < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :login
      t.string  :email
      t.string  :name
      t.string  :remember_token
      t.string  :crypted_password
      t.string  :salt
      t.date    :remember_token_expires_at
      t.integer :account_id
      t.boolean :admin
    end
  end

  def self.down
    drop_table :users
  end
end
