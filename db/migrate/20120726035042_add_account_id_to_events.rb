class AddAccountIdToEvents < ActiveRecord::Migration
  def up
    add_column :events, :account_id, :integer
  end

  def down
    remove_column :events, :account_id
  end
end
