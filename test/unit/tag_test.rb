require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:tag)
  end

  should_require_attributes :name
end
