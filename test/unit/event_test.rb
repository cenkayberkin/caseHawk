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
#  start_date   :date
#  start_time   :time
#  end_date     :date
#  end_time     :time
#  remind       :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#  completed_at :datetime
#  starts_at    :datetime
#  ends_at      :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  should_validate_presence_of :name
  should_validate_presence_of :creator_id
  should_have_many :taggings
  should_have_many :tag_records, :through => :taggings

  context "creator" do
    setup { @event = Factory(:event) }
    should_eventually "be a user" do
    end
  end
  
  context "owner" do
    setup { @event = Factory(:event) }
    should_eventually "be a user" do
    end
  end

  context "saving a record" do
    setup { AllDay.create! Factory.attributes_for(:all_day) }
    should_change "Event.count", :by => 1
  end

  context "finding events by day" do
    setup do
      @number_yesterday = 7
      @number_today = 13
      @number_yesterday.times {
        Factory.create :event, :start_date => Date.yesterday
      }
      @number_today.times {
        Factory.create :event, :start_date => Date.today
      }
    end
    should "find just yesterday's" do
      assert_equal @number_yesterday, Event.day(Date.yesterday).count
    end
    should "find just today's" do
      assert_equal @number_today, Event.day(Date.today).count
    end
    should "find just today's with the Event#day scope" do
      assert_equal @number_today, Event.today.count
    end
  end
  
  context "finding events by week offset" do
    setup do
      @number_future = 4
      @number_past = 9
      @number_future.times {
        Factory.create :event, :start_date => Date.today + @number_future.weeks
      }
      @number_past.times {
        Factory.create :event, :start_date => Date.today - @number_past.weeks
      }
    end
    should "find events from the past" do
      assert_equal @number_past, Event.weeks_ago(@number_past).count
    end
    should "find events from the FUTURE" do
      assert_equal @number_future, Event.weeks_ahead(@number_future).count
    end
  end
  
  context "finding events for a given week" do
    setup do
      @number = 14
      @date = Date.today + @number.weeks
      @number.times {
        Factory.create :event, :start_date => @date
      }
    end
    should "find the right number of events based on Date object" do
      assert_equal @number, Event.week_of(@date).count
    end
    should "find the right number of events based on String" do
      assert_equal @number, Event.week_of(@date.to_s).count
    end
  end

  context "finding events" do
    setup {
      3.times { Factory.create :event, :start_date => Date.today.beginning_of_week - 2.days }
      6.times { Factory.create :event, :start_date => 1.week.ago.beginning_of_week - 2.days }
      4.times { Factory.create :event, :start_date => 2.week.ago.beginning_of_week - 2.days }
    }
    context "by week param" do
      setup { @events = Event.find_by(:week => 1) }
      should "find only the events in the right week" do
        assert_equal Event.find(:all, :conditions => ["start_date >= ? AND end_date <= ?",
                                                      1.week.ago.beginning_of_week.to_date,
                                                      1.week.ago.end_of_week.to_date]),
                     @events
      end
    end
    context "by start date and end date" do
      setup {
        @start_date = Date.today.beginning_of_week - 3.days
        @end_date = Date.today.beginning_of_week - 1.days
        @events = Event.find_by(:start_date => @start_date,
                                :end_date   => @end_date)
      }
      should "find only the events matching the right timeframe" do
        assert_equal Event.find(:all, :conditions => ["start_date >= ? AND end_date <= ?",
                                                      @start_date, @end_date]),
                     @events
      end
    end
    context "by param id" do
      should "find only the events matching the right timeframe" do
        assert_equal [Event.last],
                     Event.find_by(:id => Event.last.id)
      end
    end
    context "by tags" do
      setup {
        Factory.create :event,   :tags => "one, two",    :start_date => Date.yesterday
        Factory.create :all_day, :tags => "two, three",  :start_date => Date.yesterday
        Factory.create :task,    :tags => "three, four", :start_date => Date.yesterday
      }
      should "find events by a single tag name" do
        assert_equal Event.all.select {|e| e.tag_records.include? Tag.find_or_create_by_name("one") },
                     Event.find_by(:tags => ['one'])
      end
      should "find events by multiple tags (matches any tags)" do
        assert_equal Event.all.select {|e|
                       e.tag_records.include?(Tag.find_or_create_by_name("two")) ||
                       e.tag_records.include?(Tag.find_or_create_by_name("three"))
                     },
                     Event.find_by(:tags => ['two', 'three'])
      end
    end
  end
  
  context "setting events with a string" do
    setup do
      @starttime = "2/8/2005 2:30pm"
      @endtime = "2/8/2005 6:14pm"
      @event = Appointment.new(:start_string => @starttime, :end_string => @endtime)
    end
    should "fill in date and time attributes" do
      assert_equal @event.start_date.class, Date
      assert_equal @event.start_time.class, Time
      assert_equal @event.end_date.class, Date
      assert_equal @event.end_time.class, Time
      assert_equal Time.parse(@starttime), Time.parse(@event.start_string)
      assert_equal Time.parse(@endtime), Time.parse(@event.end_string)
    end
  end
  
  context "Tagging an Event" do
    context "tagging an event explicitly" do
      setup do
        @event = Factory(:event)
        @event.taggings.create! :tag => Factory(:tag),
                                :creator => Factory(:user)
      end
      should "have tag records" do
        assert !@event.tag_records.blank?
      end
      should_change 'Tagging.count'
      should_change 'Tag.count'
    end
  
    context "tagging an event with a string" do
      setup do
        @event = Factory(:event)
        @event.tags = "BIG, little, super awesome"
      end
      should "have tag records" do
        assert !@event.tag_records.blank?
      end
      should_change 'Tagging.count'
      should_change 'Tag.count'
      should "have right tag count" do
        assert_equal 3, @event.tag_records.size
      end
      should "have each tag" do
        ["BIG", "little", "super awesome"].each {|name|
          assert @event.tag_records.include?(Tag.find_by_name(name))
        }
      end
      should "remove previous tags" do
        @event.tags = "new, better"
        ["BIG", "little", "super awesome"].each {|name|
          assert !@event.tag_records.include?(Tag.find_by_name(name))
        }
      end
    end
  
    context "tagging an unsaved event with a string" do
      setup do
        @event = Factory.build(:event)
        @event.tags = "Another, Tag Test"
      end
      should "be an unsaved event" do
        assert @event.new_record?
      end
      should "have right tagging count" do
        assert_equal 2, @event.taggings.size
      end
      should "have built each tag record" do
        assert Tag.find_by_name('Another')
        assert Tag.find_by_name('Tag Test')
      end
      should "have built an unsaved tagging for each tag" do
        ["Another", "Tag Test"].each do |name|
          assert @event.taggings.detect {|tagging|
            tagging.tag_id == Tag.find_by_name(name).id
          }.new_record?
        end
      end
    end
  
    context "tagging an unsaved event with a string and then saving it" do
      setup do
        @event = Factory.build(:event)
        @event.tags = "Another, Tag Test"
        @event.save
      end
      should "create valid tagging records" do
        @event.taggings.each {|tagging| assert_valid tagging }
      end
      should_change 'Tag.count'
      should_change 'Tagging.count'
      should "save all tagging records" do
        assert_equal 2, @event.taggings.count
      end
    end
  end
end
