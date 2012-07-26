class AddAutomatedToTaggings < ActiveRecord::Migration
  def up
    add_column :taggings, :automated, :boolean, :default => false, :null => false
  end

  def down
    remove_column :taggings, :automated
  end
end
