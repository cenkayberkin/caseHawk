require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:tagging)
  end
 
end
