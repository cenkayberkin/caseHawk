class CreateRecentTags < ActiveRecord::Migration
  def up
    create_table :recent_tags do |t|
      t.integer :user_id
      t.integer :tag_id
      t.integer :count, :default => 0, :null => false

      t.datetime :updated_at
    end

  end

  def down
    drop_table :recent_tags
  end
end
