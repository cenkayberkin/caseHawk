class AddAccountIdToTags < ActiveRecord::Migration
  def up
    add_column :tags, :account_id, :integer
  end

  def down
    remove_column :tags, :account_id
  end
end
