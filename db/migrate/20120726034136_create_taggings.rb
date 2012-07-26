class CreateTaggings < ActiveRecord::Migration
  def up
    create_table :taggings do |t|
      t.integer :creator_id
      t.integer :tag_id
      t.string  :taggable_type
      t.integer :taggable_id
      t.timestamps
    end
  end

  def down
    drop_table :taggings
  end
end
