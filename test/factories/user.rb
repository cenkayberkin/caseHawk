Factory.define :user do |user|
  user.login 'frank'
  user.password 'password'
  user.password_confirmation 'password'
  user.email 'frank@casehawk.com'

  user.association :account, :factory => :account
end