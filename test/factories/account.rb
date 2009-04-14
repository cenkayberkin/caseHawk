Factory.define :account do |f|
  f.full_domain 'casehawk.com'
end

Factory.define :subscription do |f|
  f.association :subscription_plan
  f.association :account
  f.user_limit 3
  f.next_renewal_at 1.day.ago
  f.amount 10
  f.card_number "XXXX-XXXX-XXXX-1111"
  f.card_expiration "05-2012"
  f.billing_id "foo"
end
Factory.define :subscription_plan do |f|
  f.renewal_period 5
end