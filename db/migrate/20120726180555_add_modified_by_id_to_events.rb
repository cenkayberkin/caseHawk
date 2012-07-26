class AddModifiedByIdToEvents < ActiveRecord::Migration
  def up
    add_column :events, :modified_by, :integer
    add_column :event_versions, :modified_by, :integer
  end

  def down
    remove_column :event_versions, :modified_by
    remove_column :events, :modified_by
  end
end
