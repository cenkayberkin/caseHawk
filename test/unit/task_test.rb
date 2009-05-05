require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:task)
  end
 
  context "given a valid task" do
    setup do
      @event = Factory(:task)
    end
    should "have a start date" do
      assert @event.start_date
    end   
    should "have no end date" do
      assert_nil @event.end_date
    end   
    should "have no start time" do
      assert_nil @event.start_time
    end   
    should "have no end time" do
      assert_nil @event.end_time
    end   
    should_eventually "be completable" do
    end
  end
end
