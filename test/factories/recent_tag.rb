Factory.define :recent_tag do |recent_tag|
  recent_tag.association :user
  recent_tag.association :tag
  recent_tag.count { rand(100).to_i }
end
