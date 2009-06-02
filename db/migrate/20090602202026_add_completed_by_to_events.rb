class AddCompletedByToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :completed_by, :string
  end

  def self.down
    remove_column :events, :completed_by
  end
end
