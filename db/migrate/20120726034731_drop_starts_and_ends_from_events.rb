class DropStartsAndEndsFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :start_date
    remove_column :events, :start_time
    remove_column :events, :end_date
    remove_column :events, :end_time
  end

  def down
    add_column :events, :start_date, :date
    add_column :events, :start_time, :time
    add_column :events, :end_date, :date
    add_column :events, :end_time, :time
  end
end
