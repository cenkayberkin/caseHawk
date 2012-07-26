class ChangeEventKind < ActiveRecord::Migration
  def change
    rename_column(:events, :kind, :event_type)
  end
end
