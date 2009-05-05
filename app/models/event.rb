# == Schema Information
#
# Table name: events
#
#  id          :integer(4)      not null, primary key
#  creator_id  :integer(4)      not null
#  owner_id    :integer(4)
#  location_id :integer(4)
#  kind        :string(255)     not null
#  name        :string(255)     not null
#  start_date  :date
#  start_time  :time
#  end_date    :date
#  end_time    :time
#  remind      :boolean(1)
#  created_at  :datetime
#  updated_at  :datetime
#

class Event < ActiveRecord::Base

  self.inheritance_column = 'event_type'

  belongs_to :location
  has_many   :taggings, :as => :taggable
  has_many   :tags, :through => :taggings
  
  validates_presence_of :name
  validates_presence_of :creator_id
  validates_presence_of :kind

  named_scope :day, lambda { |day| { :conditions => "start_date LIKE '#{day}%'
                                      OR end_date LIKE '#{day}%'
                                      OR '#{day}' BETWEEN start_date AND end_date" } }
  
  def self.today
    # This is basically a named scope that extends the :day scope for DRYness
    Event.day(Date.today)
  end
  
  def tags=(string)
    old_tag_ids = tag_ids.dup
    # break by comma and find a Tag for each piece
    string.split(/,\s*/).map do |part|
      Tag.find_or_create_by_name(part)
    end.each do |tag|
      # save an appropriate tagging
      taggings.send new_record? ? :build : :create!,
                    :tag => tag,
                    :taggable => self
      old_tag_ids.delete tag.id
    end
    # remove implicitly deleted tags (ones that weren't passed)
    old_tag_ids.each {|tag_id| taggings.find_by_tag_id(tag_id).destroy }
  end
end
