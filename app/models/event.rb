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
#  completed_by :integer(4)
#  account_id   :integer(4)
#  version      :integer(4)
#  deleted_at   :datetime
#

class Event < ActiveRecord::Base

  acts_as_versioned
  acts_as_paranoid
  
  belongs_to :account
  belongs_to :creator, :class_name => 'User'
  belongs_to :modified_by, :class_name => 'User'
  belongs_to :owner, :class_name => 'User'
  belongs_to :location
  belongs_to :completed_by, :class_name => 'User', :foreign_key => "completed_by"
  has_many   :taggings, :as => :taggable, :extend => Tagging::Extension
  has_many   :tag_records, :through => :taggings, :source => :tag

  # see Taggings::Extension for details on why we use delegate
  delegate :tags,  :to => :taggings
  delegate :tags=, :to => :taggings
  
  validates_presence_of :name
  validates_presence_of :creator_id
  validate :requires_subclassing

  named_scope :ordered, :order => :starts_at
  named_scope :day, proc {|day|
    { :conditions => "   DATE(starts_at) = '#{day}%'
                      OR DATE(ends_at) = '#{day}%'
                      OR DATE('#{day}') BETWEEN DATE(starts_at) AND DATE(ends_at)" }
  }
  named_scope :between, proc {|range_start, range_end|
    { :conditions => "   DATE(starts_at) BETWEEN DATE('#{range_start}') AND DATE('#{range_end}')
                      OR DATE(ends_at) BETWEEN DATE('#{range_start}') AND DATE('#{range_end}')
                      OR (  DATE('#{range_start}') BETWEEN DATE(starts_at) AND DATE(ends_at)
                        AND DATE('#{range_end}') BETWEEN DATE(starts_at) AND DATE(ends_at) ) "}
  }
  named_scope :with_tags, proc {|taglist|
    { :conditions => [" tags.name IN (?) ", taglist],
      :joins => {:taggings => :tag} }
  }
  named_scope :of_account, proc {|acct|
    { :conditions => [" account_id = ? ", acct] }
  }
  
  #
  # These class methods DRYly extend the named scopes
  #
  
  def self.today
    Event.day(Date.today)
  end
    
  def self.week_of(date)
    date = Date.parse(date) if date.is_a?(String)
    # Correct to get Sun - Sat week
    Event.between(date.beginning_of_week, date.end_of_week)
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
      builder.week_of(params[:week]) if params[:week]
      builder.between(params[:starts_at], params[:ends_at]) if params[:starts_at] and params[:ends_at]
      builder.with_tags(params[:tags]) if params[:tags]
    end.find(:all).uniq
  end
  
  # Find a good way to convert strings to date
  def self.parse(str)
    return nil if str.blank?
    # Since Chronic can't handle "November  6, 2009 01:00 PM", let's try Time.parse first, which can:
    Time.parse(str) rescue Chronic.parse(str)
  end

  # used by new event form in javascript building of tags
  def tag_names=(names)
    names.each do |name|
      taggings.send new_record? ? :build : :create!, 
                    :tag => Tag.find_or_create_by_name(name), 
                    :taggable => self
    end
  end

  # include our custom getters in json and other attribute collections
  def attribute_names
    super + [
      "type",
      "starts_at", "starts_at_time", "starts_at_date",
      "ends_at",   "ends_at_time",   "ends_at_date"
    ]
  end

  # include STI key in json attributes
  def to_json(options = {})
    super(options.merge({:only => attribute_names + ["type"]}))
  end

  # the 'completed' param can set intelligently set completed_at
  def completed=(value)
    self.completed_at = value.blank? ? nil : Time.now
  end

  # Parse any input from the user with parsing to allow natural language entry
  def starts_at=(string)
    write_attribute :starts_at, Event.parse(string.to_s)
  end
  def ends_at=(string)
    write_attribute :ends_at,   Event.parse(string.to_s)
  end
  
  def starts_at_time=(string)
    write_attribute :starts_at,
                    (starts_at || Date.today).midnight + 
                    (Event.parse(string.to_s) || starts_at).seconds_since_midnight
  end
  def ends_at_time=(string)
    write_attribute :ends_at,
                    (ends_at || Date.today).midnight + 
                    (Event.parse(string.to_s) || ends_at).seconds_since_midnight
  end

  def starts_at_date=(string)
    write_attribute :starts_at, Event.parse(string.to_s).to_date.to_time + (starts_at || Time.now).seconds_since_midnight
  end
  def ends_at_date=(string)
    write_attribute :ends_at,   Event.parse(string.to_s).to_date.to_time + (ends_at || Time.now).seconds_since_midnight
  end

  def starts_at_time; starts_at && starts_at.strftime("%I:%M %p") end
  def ends_at_time;   ends_at   && ends_at.strftime(  "%I:%M %p") end
  def starts_at_date; starts_at && starts_at.to_date              end
  def ends_at_date;   ends_at   && ends_at.to_date                end

  def completable?
    false
  end
  
  def timed?
    false
  end
  
  def to_html_attributes
    {
      "data-event-id"       => id,
      "data-name"           => name,
      "data-type"           => type,
      "data-timed"          => timed?.to_s,
      "data-completable"    => completable?.to_s,
      "data-starts-at"      => starts_at.blank? ? nil : starts_at.to_s(:full),
      "data-starts-at-time" => starts_at_time,
      "data-starts-at-date" => starts_at_date.to_s, 
      "data-ends-at"        => ends_at.blank? ? nil : ends_at.to_s(:full), 
      "data-ends-at_time"   => ends_at_time,
      "data-ends-at_date"   => ends_at_date.to_s,
      "data-tags"           => tags
    }
  end
  
  protected

    def requires_subclassing
      errors.add_to_base "Event type must be specified" if Event == self.class
    end

end
