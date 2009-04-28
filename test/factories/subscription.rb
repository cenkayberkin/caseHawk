Factory.define :subscription do |f|
  f.association :account
  f.association :subscription_plan
  f.user_limit 3
  f.next_renewal_at 1.day.ago
  f.amount 10
  f.card_number "XXXX-XXXX-XXXX-1111"
  f.card_expiration "05-2012"
  f.billing_id "foo"
end
