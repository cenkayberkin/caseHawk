Factory.define :user do |user|
  user.sequence(:login) {|n| "Agent 00#{n}" }
  user.password 'longpassword'
  user.password_confirmation 'longpassword'
  user.sequence(:email) {|n| "00#{n}@casehawk.com" }
  user.association :account
end