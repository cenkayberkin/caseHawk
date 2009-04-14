require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:event)
  end
 
end
