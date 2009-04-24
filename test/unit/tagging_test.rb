require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < ActiveSupport::TestCase

  should_validate_presence_of :tag
  should_validate_presence_of :taggable
  should_validate_presence_of :creator

  should "be valid with factory" do
    assert_valid Factory.build(:tagging)
  end

  context "tagging an Event" do
    setup do
      @tagging = Factory(:tagging)
    end

    should "description" do
      
    end
  end
  
end
