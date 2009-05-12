# == Schema Information
#
# Table name: events
#
#  id          :integer(4)      not null, primary key
#  creator_id  :integer(4)      not null
#  owner_id    :integer(4)
#  location_id :integer(4)
#  type        :string(255)     not null
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

  belongs_to :location
  has_many   :taggings, :as => :taggable
  has_many   :tag_records, :through => :taggings, :source => :tag
  
  validates_presence_of :name
  validates_presence_of :creator_id
  validate :requires_subclassing

  named_scope :day, proc {|day|
    { :conditions => "   start_date LIKE '#{day}%'
                      OR end_date LIKE '#{day}%'
                      OR '#{day}' BETWEEN start_date AND end_date" }
  }
  named_scope :between, proc {|range_start, range_end|
    { :conditions => "   start_date BETWEEN '#{range_start}' AND '#{range_end}'
                      OR end_date BETWEEN '#{range_start}' AND '#{range_end}'"}
  }
  
  #
  # These class methods DRYly extend the named scopes
  #
  
  def self.today
    Event.day(Date.today)
  end
    
  def self.week_of(date)
    day = case date 
            when String then Date.parse(date)
            when Date   then date
            else p date.class
          end
          
    Event.between(day.beginning_of_week, day.end_of_week)
  end

  def self.this_week
    Event.week_of(Date.today)
  end

  def self.weeks_ahead(w)
    Event.week_of(Date.today + w.weeks)
  end
  
  def self.weeks_ago(w)
    Event.week_of(Date.today - w.weeks)
  end
  
  
  def tags
    TagParser.un_parse tag_records.map(&:name)
  end

  def tags=(string)
    old_tag_ids = tag_record_ids.dup
    TagParser.parse(string).tags.map do |part|
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

  protected

    def requires_subclassing
      errors.add_to_base "Event type must be specified" if Event == self.class
    end

end
