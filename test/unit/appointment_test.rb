require File.dirname(__FILE__) + '/../test_helper'

class AppointmentTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:appointment)
  end
 
  setup do
    @event = Factory(:appointment)
  end
  
  should_eventually "have start date" do
  end
  should_eventually "have end date" do
  end
  should_eventually "have start time" do
  end
  should_eventually "have end time" do
  end

end
