Factory.define :event do |e|
  e.creator_id 1
  e.kind "Appointment"
  e.name "Meeting with staff at the office"
  e.start_date "2009-04-15"
  e.start_time "13:30"
  e.end_date "2009-04-15"
  e.end_time "15:00"
  e.remind 0
end

# Factory.define :task,         :parent => :event
# Factory.define :deadline,     :parent => :event
# Factory.define :appointment,  :parent => :event