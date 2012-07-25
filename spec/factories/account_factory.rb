FactoryGirl.define do
  factory(:account) do
    name Faker::Company.name
    full_domain 'test_host'
  end
end
