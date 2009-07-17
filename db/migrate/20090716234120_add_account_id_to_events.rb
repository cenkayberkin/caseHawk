class AddAccountIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :account_id, :integer
  end

  def self.down
    remove_column :events, :account_id
  end
end
