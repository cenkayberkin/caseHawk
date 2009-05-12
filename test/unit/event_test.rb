# == Schema Information
# Schema version: 20090505212954
#
# Table name: events
#
#  id         :integer(4)      not null, primary key
#  creator_id :integer(4)      not null
#  owner_id   :integer(4)
#  event_type :string(255)     not null
#  name       :string(255)     not null
#  start_date :date
#  start_time :time
#  end_date   :date
#  end_time   :time
#  remind     :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  should_validate_presence_of :name
  should_validate_presence_of :creator_id
  should_validate_presence_of :type
  should_have_many :taggings
  should_have_many :tags, :through => :taggings

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
  
  

  context "Tagging an Event" do
    context "tagging an event explicitly" do
      setup do
        @event = Factory(:event)
        @event.taggings.create! :tag => Factory(:tag),
                                :creator => Factory(:user)
      end
      should "have tag records" do
        assert !@event.tags.blank?
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
        assert !@event.tags.blank?
      end
      should_change 'Tagging.count'
      should_change 'Tag.count'
      should "have right tag count" do
        assert_equal 3, @event.tags.size
      end
      should "have each tag" do
        ["BIG", "little", "super awesome"].each {|name|
          assert @event.tags.include?(Tag.find_by_name(name))
        }
      end
      should "remove previous tags" do
        @event.tags = "new, better"
        ["BIG", "little", "super awesome"].each {|name|
          assert !@event.tags.include?(Tag.find_by_name(name))
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
