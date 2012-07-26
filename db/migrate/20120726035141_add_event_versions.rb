class AddEventVersions < ActiveRecord::Migration
  def up
    Event.create_versioned_table
  end

  def down
    Event.drop_versioned_table
  end
end
