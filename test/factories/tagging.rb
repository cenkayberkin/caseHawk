Factory.define :tagging do |tagging|
  tagging.association :creator, :factory => :user
  tagging.association :tag
  tagging.association :taggable, :factory => :event
end
