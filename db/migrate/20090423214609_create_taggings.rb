class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.integer :creator_id
      t.integer :tag_id
      t.string  :taggable_type
      t.integer :taggable_id
      t.timestamps
    end

  end

  def self.down
    drop_table :taggings
  end
end
