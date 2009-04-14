require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  should_require_attributes :login
  should_require_attributes :email
end