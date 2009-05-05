class ChangeEventKind < ActiveRecord::Migration
  def self.up
    rename_column(:events, :kind, :event_type)
  end

  def self.down
    rename_column(:events, :event_type, :kind)
  end
end
