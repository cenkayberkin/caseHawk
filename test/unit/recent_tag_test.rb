require File.dirname(__FILE__) + '/../test_helper'

class RecentTagTest < ActiveSupport::TestCase

  should_belong_to :user
  should_belong_to :tag

end
