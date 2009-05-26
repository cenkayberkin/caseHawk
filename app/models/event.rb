# == Schema Information
#
# Table name: events
#
#  id           :integer(4)      not null, primary key
#  creator_id   :integer(4)      not null
#  owner_id     :integer(4)
#  location_id  :integer(4)
#  type         :string(255)     not null
#  name         :string(255)     not null
#  remind       :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#  completed_at :datetime
#  starts_at    :datetime
#  ends_at      :datetime
#

class Event < ActiveRecord::Base

  belongs_to :location
  belongs_to :creator, :class_name => 'User'
  has_many   :taggings, :as => :taggable
  has_many   :tag_records, :through => :taggings, :source => :tag
  
  validates_presence_of :name
  validates_presence_of :creator_id
  validate :requires_subclassing

  named_scope :day, proc {|day|
    { :conditions => "   starts_at LIKE '#{day}%'
                      OR ends_at LIKE '#{day}%'
                      OR DATE('#{day}') BETWEEN DATE(starts_at) AND DATE(ends_at)" }
  }
  named_scope :between, proc {|range_start, range_end|
    { :conditions => "   DATE(starts_at) BETWEEN DATE('#{range_start}') AND DATE('#{range_end}')
                      OR DATE(ends_at) BETWEEN DATE('#{range_start}') AND DATE('#{range_end}')"}
  }
  
  named_scope :with_tags, proc {|taglist|
    { :conditions => [" tags.name IN (?) ", taglist],
      :joins => {:taggings => :tag} }
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
          end
    Event.between(day.beginning_of_week, day.end_of_week)
  end

  def self.this_week
    Event.week_of(Date.today)
  end

  def self.weeks_ahead(w)
    Event.week_of(Date.today + w.to_i.weeks)
  end
  
  def self.weeks_ago(w)
    Event.week_of(Date.today - w.to_i.weeks)
  end
  
  def self.find_by(params)
    return [find_by_id(params[:id])] if params[:id]
    scope_builder do |builder| # from Ryan Bates' scope_builder
      builder.weeks_ago(params[:week]) if params[:week]
      builder.between(params[:start_date], params[:end_date]) if params[:start_date] and params[:end_date]
      builder.with_tags(params[:tags]) if params[:tags]
    end.find(:all).uniq
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

  def to_json(options = {})
    options[:only] = attribute_names + ["type", "start", "end"]
    super(options)
  end
  
  # setting the start_time, start_date, end_time, or end_date
  # allows for changing just a portion of the starts_at or
  # ends_at values.
  def start_time=(string)
    return unless time = Time.parse(string.to_s) rescue nil
    self.starts_at =
         starts_at.beginning_of_day.advance :hours   => time.hour,
                                            :minutes => time.min,
                                            :seconds => time.sec
  end
  def start_time; starts_at; end
  
  def start_date=(string)
    return unless date = Date.parse(string.to_s) rescue nil
    self.starts_at = "#{date} #{(starts_at || Date.today).strftime("%T")}"
  end
  def start_date; starts_at.to_date; end
  

  def end_time=(string)
    return unless time = Time.parse(string.to_s) rescue nil
    self.ends_at =
         ends_at.beginning_of_day.advance :hours   => time.hour,
                                          :minutes => time.min,
                                          :seconds => time.sec
  end
  def end_time; ends_at; end
  
  def end_date=(string)
    return unless date = Date.parse(string.to_s) rescue nil
    self.ends_at = "#{date} #{(ends_at || Date.today).strftime("%T")}"
  end
  def end_date; ends_at.to_date; end

  protected

    def requires_subclassing
      errors.add_to_base "Event type must be specified" if Event == self.class
    end

end
