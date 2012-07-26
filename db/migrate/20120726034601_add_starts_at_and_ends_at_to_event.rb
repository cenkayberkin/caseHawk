class AddStartsAtAndEndsAtToEvent < ActiveRecord::Migration
  def up
    add_column :events, :starts_at, :datetime
    add_column :events, :ends_at, :datetime
  end

  def down
    remove_column :events, :starts_at
    remove_column :events, :ends_at
  end
end
