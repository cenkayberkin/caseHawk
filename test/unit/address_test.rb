require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:address)
  end
 
end
