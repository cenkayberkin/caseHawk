require File.dirname(__FILE__) + '/../test_helper'

class AllDayTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:all_day)
  end
  
  context "given a valid one-day event" do
    setup do
      @event = Factory.build(:all_day)
    end
    should "have a start date" do
      assert @event.start_date
    end
    should "have an end date" do
      assert @event.end_date
    end
    should "have no start time" do
      assert_nil @event.start_time
    end
    should "have no end time" do
      assert_nil @event.end_time
    end
    should "be able to be only one day" do
      assert_equal @event.start_date, @event.end_date
    end
    should_eventually "be able to span several days" do
    end
  end
end