require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:task)
  end
 
  setup do
    @event = Factory(:task)
  end
  should_eventually "have a start date" do
  end
  should_eventually "have no end date" do
  end
  should_eventually "have no start time" do
  end
  should_eventually "have no end time" do
  end
  should_eventually "be completable" do
  end
 
end
