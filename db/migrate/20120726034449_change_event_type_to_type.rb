class ChangeEventTypeToType < ActiveRecord::Migration
  def change
    rename_column :events, :event_type, :type
  end
end
