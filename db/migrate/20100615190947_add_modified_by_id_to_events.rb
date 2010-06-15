class AddModifiedByIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :modified_by, :integer
    add_column :event_versions, :modified_by, :integer
  end

  def self.down
    remove_column :event_versions, :modified_by
    remove_column :events, :modified_by
  end
end
