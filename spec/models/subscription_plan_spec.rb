# == Schema Information
#
# Table name: subscription_plans
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  amount         :decimal(10, 2)
#  created_at     :datetime
#  updated_at     :datetime
#  user_limit     :integer(8)
#  renewal_period :integer(8)      default(1)
#  setup_amount   :decimal(10, 2)
#  trial_period   :integer(8)      default(1)
#

require File.dirname(__FILE__) + '/../spec_helper'
include ActionView::Helpers::NumberHelper

describe SubscriptionPlan do
  before(:each) do
    @plan = subscription_plans(:basic)
  end

  it "should return a formatted name" do
    @plan.to_s.should == "#{@plan.name} - #{number_to_currency(@plan.amount)} / month"
  end
  
  it "should return the name for URL params" do
    @plan.to_param.should == @plan.name
  end
end
