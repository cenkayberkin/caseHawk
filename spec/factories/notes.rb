# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note do
    case_id 1
    notes "MyText"
  end
end
