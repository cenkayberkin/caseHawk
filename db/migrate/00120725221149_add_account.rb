class AddAccount < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string  :name
      t.string  :full_domain
      t.integer :subscription_discount_id

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
