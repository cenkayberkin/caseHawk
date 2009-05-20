Factory.define :event, :class => 'AllDay' do |e|
  e.creator_id 1
  e.name "Meeting with staff at the office"
  e.starts_at "2009-04-15 13:30"
  e.ends_at   "2009-04-15 15:00"
  e.remind 0
end

Factory.define :all_day do |e|
  e.creator_id 1
  e.name "Big Tuna Birthday"
  e.starts_at "2009-04-15 00:00"
  e.ends_at   "2009-04-15 00:00"
  e.remind 0
end

Factory.define :appointment do |e|
  e.creator_id 1
  e.name "Meeting with staff at the office"
  e.starts_at "2009-04-15 13:30"
  e.ends_at   "2009-04-15 15:00"
  e.remind 0
end

Factory.define :deadline do |e|
  e.creator_id 1
  e.name "Turn it in!"
  e.starts_at "2009-04-15 13:30"
  e.remind 0
end

Factory.define :task do |e|
  e.creator_id 1
  e.name "Things to do"
  e.starts_at "2009-04-15 00:00"
  e.remind 0
end
