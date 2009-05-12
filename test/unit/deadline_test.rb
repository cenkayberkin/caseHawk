require File.dirname(__FILE__) + '/../test_helper'

class DeadlineTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:deadline)
  end
  
  context "given a valid deadline" do
    setup do
      @event = Factory(:deadline)
    end
    should "have start date" do
      assert @event.start_date
    end   
    should "have start time" do
      assert @event.start_time
    end   
    should "have no end date" do
      assert_nil @event.end_date
    end   
    should "have no end time" do
      assert_nil @event.end_time
    end   
    should_eventually "be completable" do
    end
  end
end