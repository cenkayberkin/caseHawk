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

require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  should_validate_presence_of :name
  should_validate_presence_of :creator_id
  should_have_many :taggings
  should_have_many :tag_records, :through => :taggings
  should_belong_to :creator, :location

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
    setup { Factory.create(:all_day) }
    should_change "Event.count", :by => 1
  end

  context "moving an event" do
    setup { @event = Factory.create(:event) }
    context "forward one day by starts_at" do
      setup {
        @event.update_attributes(
          :starts_at_date => @event.starts_at_date+1.day
        )
      }
      should_change "@event.starts_at", :by => 1.day
      should_change "@event.ends_at", :by => 1.day
    end
    context "backward one day by ends_at" do
      setup {
        @event.update_attributes(
          :ends_at_date => @event.ends_at_date-1.day
        )
      }
      should_not_change "@event.starts_at"
      should_not_change "@event.ends_at"
    end    
  end

  context "parsing times" do
    should "return nil for nil" do
      assert_equal nil, Event.parse(nil)
    end
    should "return nil for blank string" do
      assert_equal nil, Event.parse('')
    end
  end
  

  context "finding events by day" do
    setup do
      @number_yesterday = 7
      @number_today = 13
      @number_yesterday.times {
        Factory.create :event, :starts_at => Date.yesterday
      }
      @number_today.times {
        Factory.create :event, :starts_at => Date.today
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
        Factory.create :event, :starts_at => Date.today + @number_future.weeks
      }
      @number_past.times {
        Factory.create :event, :starts_at => Date.today - @number_past.weeks
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
        Factory.create :event, :starts_at => @date
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
      3.times { Factory.create :event, :starts_at => Date.today.beginning_of_week - 2.days }
      6.times { Factory.create :event, :starts_at => 1.week.ago.beginning_of_week - 2.days }
      4.times { Factory.create :event, :starts_at => 2.week.ago.beginning_of_week - 2.days }
    }
    context "by week param" do
      setup { @events = Event.find_by(:week => 1.week.ago.to_date.to_s) }
      should "find only the events in the right week" do
        assert_equal Event.find(:all, :conditions => ["starts_at >= ? AND ends_at <= ?",
                                                      1.week.ago.beginning_of_week.to_date,
                                                      1.week.ago.end_of_week.to_date]),
                     @events
      end
    end
    context "by start date and end date" do
      setup {
        @starts_at = Date.today.beginning_of_week - 3.days
        @ends_at = Date.today.beginning_of_week - 1.days
        @events = Event.find_by(:starts_at => @starts_at,
                                :ends_at   => @ends_at)
      }
      should "find only the events matching the right timeframe" do
        assert_equal Event.find(:all, :conditions => ["starts_at >= ? AND ends_at <= ?",
                                                      @starts_at, @ends_at]),
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
        Factory.create :event,   :tag_names => ["one","two"],    :starts_at => Date.yesterday
        Factory.create :all_day, :tag_names => ["two","three"],  :starts_at => Date.yesterday
        Factory.create :task,    :tag_names => ["three","four"], :starts_at => Date.yesterday
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

  context "updating chronology" do
    setup { @event = Factory.create :event }
    [:starts_at, :ends_at].each do |bound|
      context "setting #{bound}" do
        setup { @event.send("#{bound}=", 14.days.ago)}
        should_change "@event.#{bound}.to_s"
        should_change "@event.#{bound}_time"
        should_change "@event.#{bound}_date"
        should "set proper datetime" do
          assert_equal 14.days.ago.to_s, @event.send(bound).to_s
        end
      end
      context "setting time portion of #{bound}" do
        setup { @event.send("#{bound}_time=", "05:14:12 am") }
        should_change     "@event.#{bound}"
        should_change     "@event.#{bound}_time"
        should_not_change "@event.#{bound}_date"
      end
      context "setting date portion of #{bound}" do
        setup { @event.send("#{bound}_date=", 52.days.ago.to_date.to_s) }
        should_change     "@event.#{bound}"
        should_change     "@event.#{bound}_date"
        should_not_change "@event.#{bound}_time"
      end
      context "making sure we aren't bitten by a Chronic afternoon time parsing bug when setting #{bound}" do
        setup { @event.send("#{bound}_time=", "05:14:12 pm") }
        should_change     "@event.#{bound}"
        should_change     "@event.#{bound}_time"
        should_not_change "@event.#{bound}_date"
      end
    end
  end

  context "completing events" do
    setup { @event = Factory(:task) }
    context "by setting the completed attribute" do
      setup { @event.update_attributes(:completed => '1') }
      should_change "@event.completed_at"
      should "set event completed to right about now" do
        assert @event.completed_at > 2.seconds.ago
        assert @event.completed_at < 1.second.from_now
      end
    end
  end

  context "uncompleting events" do
    setup { @event = Factory(:task, :completed_at => 2.days.ago) }
    context "by setting the completed attribute to something blank" do
      setup { @event.update_attributes(:completed => '') }
      should_change "@event.completed_at"
      should "set event completed to nil" do
        assert !@event.completed_at
      end
    end
  end

  context "serializing to JSON" do
    setup {
      @event = Factory(:task, :completed_at => 2.days.ago)
      @json = ActiveSupport::JSON.decode(@event.to_json)
    }
    should "have type attribute" do
      assert @json.has_key?("type")
    end
    should "have custom time attributes" do
      assert @json.has_key?("starts_at_time")
      assert @json.has_key?("ends_at_time")
    end
    should "have custom date attributes" do
      assert @json.has_key?("starts_at_date")
      assert @json.has_key?("ends_at_date")
    end
    should "have standard attributes" do
      Event.columns.each do |column|
        unless ["owner_id", "creator_id"].include?(column.name)
          assert @json.has_key?(column.name)
        end
      end
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
  end
end
