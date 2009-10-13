class AddEventVersions < ActiveRecord::Migration
  def self.up
    Event.create_versioned_table
  end

  def self.down
    Event.drop_versioned_table
  end
end
