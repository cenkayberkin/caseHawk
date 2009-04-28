AppConfig['gateway'] = 'bogus'
Factory.define :account do |f|
  f.name 'some account'
  f.user { User.last }
  f.association :plan, :factory => :subscription_plan
  f.sequence(:full_domain) {|n| "www#{n}.casehawk.com" }
  f.creditcard do
    card = ActiveMerchant::Billing::CreditCard.new :number => '1'
    card.stubs(:valid?).returns(true)
    card.stubs(:save).returns(true)
    card
  end
  f.address do
    address = Factory.build(:subscription_address)
    address.stubs(:save!).returns(true)
    address
  end
end
