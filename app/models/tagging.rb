class Tagging < ActiveRecord::Base

  belongs_to :taggable, :polymorphic => true
  belongs_to :tag
  belongs_to :creator, :class_name => 'User'

  validates_presence_of :tag
  validates_presence_of :taggable
  validates_uniqueness_of :tag_id, :scope => [:taggable_type, :taggable_id]
end
