class AddDeletedAtToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :deleted_at, :datetime
    add_column :event_versions, :deleted_at, :datetime
  end

  def self.down
    remove_column :events, :deleted_at
    remove_column :event_versions, :deleted_at
  end
end
