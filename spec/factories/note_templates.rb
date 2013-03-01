# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note_template do
    note_template_category_id 1
    template "MyString"
  end
end
