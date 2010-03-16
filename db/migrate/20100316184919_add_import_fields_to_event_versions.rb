class AddImportFieldsToEventVersions < ActiveRecord::Migration
  def self.up
    add_column :event_versions, :uri, :string
    add_column :event_versions, :recurrance, :text
    add_column :event_versions, :uid, :string
  end

  def self.down
    remove_column :event_versions, :uid
    remove_column :event_versions, :column_name
    remove_column :event_versions, :uri
  end
end
