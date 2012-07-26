class AddCompletedAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :completed_at, :datetime
  end
end
