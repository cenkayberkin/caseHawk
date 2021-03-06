class FixModifiedByIdInEvents < ActiveRecord::Migration
  def up
    rename_column :events, :modified_by, :modified_by_id
    rename_column :event_versions, :modified_by, :modified_by_id
  end

  def down
    rename_column :events, :modified_by_id, :modified_by
    rename_column :event_versions, :modified_by_id, :modified_by
  end
end
