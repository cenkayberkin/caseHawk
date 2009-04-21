require File.dirname(__FILE__) + '/../test_helper'

class LocationTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:location)
  end
 
end
