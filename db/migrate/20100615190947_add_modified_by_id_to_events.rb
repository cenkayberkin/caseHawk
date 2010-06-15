class AddModifiedByIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :modified_by, :integer
  end

  def self.down
    remove_column :events, :modified_by
  end
end
