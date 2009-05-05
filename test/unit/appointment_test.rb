require File.dirname(__FILE__) + '/../test_helper'

class AppointmentTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:appointment)
  end
 
  context "given a valid appointment" do
    setup do
      @event = Factory(:appointment)
    end
    should "have start date" do
      assert @event.start_date
    end
    should "have end date" do
      assert @event.end_date
    end
    should "have start time" do
      assert @event.start_time
    end
    should "have end time" do
      assert @event.end_time
    end
  end
end
