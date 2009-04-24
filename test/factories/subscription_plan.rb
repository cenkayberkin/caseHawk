Factory.define :subscription_plan do |f|
  f.name 'Basic'
  f.amount 10
  f.user_limit 1
  f.renewal_period 4
end