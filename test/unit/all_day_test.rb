require File.dirname(__FILE__) + '/../test_helper'

class AllDayTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:all_day)
  end
 
end
