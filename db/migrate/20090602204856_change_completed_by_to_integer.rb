class ChangeCompletedByToInteger < ActiveRecord::Migration
  def self.up
    remove_column :events, :completed_by
    add_column :events, :completed_by, :integer
  end

  def self.down
    remove_column :events, :completed_by
    add_column :events, :completed_by, :string
  end
end
