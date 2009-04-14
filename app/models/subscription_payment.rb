# == Schema Information
#
# Table name: subscription_payments
#
#  id              :integer(4)      not null, primary key
#  account_id      :integer(8)
#  subscription_id :integer(8)
#  amount          :decimal(10, 2)  default(0.0)
#  transaction_id  :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  setup           :boolean(1)
#

class SubscriptionPayment < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :account
  
  before_create :set_account
  after_create :send_receipt
  
  def set_account
    self.account = subscription.account
  end
  
  def send_receipt
    return unless amount > 0
    if setup?
      SubscriptionNotifier.deliver_setup_receipt(self)
    else
      SubscriptionNotifier.deliver_charge_receipt(self)
    end
    true
  end
end
