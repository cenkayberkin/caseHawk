require File.dirname(__FILE__) + '/../test_helper'

class DeadlineTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:deadline)
  end
  
  setup do
    @event = Factory(:deadline)
  end
  
  should_eventually "have start date" do
  end
  should_eventually "have no end date" do
  end
  should_eventually "have start time" do
  end
  should_eventually "have no end time" do
  end
  should_eventually "be completable" do
  end
 
end
