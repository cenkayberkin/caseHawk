class AddCompletedByToEvents < ActiveRecord::Migration
  def up
    add_column :events, :completed_by, :integer
  end

  def down
    remove_column :events, :completed_by
  end
end
