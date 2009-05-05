Factory.define :event do |e|
  e.creator_id 1
  e.event_type "Appointment"
  e.name "Meeting with staff at the office"
  e.start_date "2009-04-15"
  e.start_time "13:30"
  e.end_date "2009-04-15"
  e.end_time "15:00"
  e.remind 0
end

Factory.define :all_day do |e|
  e.creator_id 1
  e.event_type "AllDay"
  e.name "Big Tuna Birthday"
  e.start_date "2009-05-15"
  e.end_date "2009-05-15"
  e.remind 0
end

Factory.define :appointment do |e|
  e.creator_id 1
  e.event_type "Appointment"
  e.name "Meeting with staff at the office"
  e.start_date "2009-04-15"
  e.start_time "13:30"
  e.end_date "2009-04-15"
  e.end_time "15:00"
  e.remind 0
end

Factory.define :deadline do |e|
  e.creator_id 1
  e.event_type "Deadline"
  e.name "Turn it in!"
  e.start_date "2009-05-15"
  e.start_time "13:30"
  e.remind 0
end

Factory.define :task do |e|
  e.creator_id 1
  e.event_type "Task"
  e.name "Things to do"
  e.start_date "2009-05-15"
  e.start_time "17:30"
  e.remind 0
end
