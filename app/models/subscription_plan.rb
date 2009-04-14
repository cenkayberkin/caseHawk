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

class SubscriptionPlan < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  # renewal_period is the number of months to bill at a time
  # default is 1
  validates_numericality_of :renewal_period, :only_integer => true, :greater_than => 0

  def to_s
    "#{self.name} - #{number_to_currency(self.amount)} / month"
  end
  
  def to_param
    self.name
  end
end
