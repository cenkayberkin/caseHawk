Factory.define :event, :class => 'Appointment' do |e|
  e.creator { User.first || Factory.create(:user) }
  e.name "Meeting with staff at the office"
  e.starts_at "2009-04-15 13:30"
  e.ends_at   "2009-04-15 15:00"
  e.account { Account.first || Factory.create(:account) }
  e.remind 0
end

Factory.define :all_day, :parent => :event, :class => 'AllDay' do |e|
  e.name "Big Tuna Birthday"
  e.starts_at "2009-04-15 00:00"
  e.ends_at   "2009-04-15 00:00"
end

Factory.define :appointment, :parent => :event do
end

Factory.define :deadline, :parent => :event, :class => 'Deadline' do |e|
  e.name "Turn it in!"
  e.starts_at "2009-04-15 13:30"
  e.ends_at nil
end

Factory.define :task, :parent => :event, :class => 'Task' do |e|
  e.name "Clean the office"
  e.starts_at "2009-04-15 00:00"
end
