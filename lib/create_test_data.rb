# Originally at: http://gist.github.com/raw/118278/a56f1302d3e7aedb0cd5a2131207ed1de369610f/CaseHawk%20Test%20Data

require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
gem 'faker'
require 'faker'

account = Account.first

randomize = 'PostgreSQL' == ActiveRecord::Base.connection.adapter_name ? 'RANDOM()' : 'RAND()'
 
# Makes a bunch of different types of events per day at a random time during work hours
(30.days.ago.to_date..90.days.from_now.to_date).each do |date|
  rand(3).times do
    start = date.beginning_of_day + 8.hours + (rand(32) * 15).minutes
    event = %w(Meet Visit See).rand
    Appointment.create :creator => User.find(:first, :order => randomize),
                       :starts_at => start,
                       :ends_at => start + (rand(16) * 15).minutes,
                       :account => account,
                       :name => "#{event} #{Faker::Name.name}",
                       :tag_names => ['dewey', 'food', 'Seattle', 'Tacoma', 'RJC', 'OP', 'appt-tag'].rand
  end
  rand(2).times do
    event = %w(birthday vacation sick trial).rand
    AllDay.create :creator => User.find(:first, :order => randomize),
                  :starts_at => date,
                  :ends_at => date + rand(4).days,
                  :account => account,
                  :name => "#{Faker::Name.name}'s #{event}",
                  :tag_names => ['dewey', 'food', 'Seattle', 'Tacoma', 'RJC', 'OP', 'allday-tag'].rand
  end
  rand(3).times do
    start = date.beginning_of_day + 8.hours + (rand(32) * 15).minutes
    event = %w(Trial: Disposition: Mediation: Hearing: Judgement: Pre-Trial:).rand
    CourtDate.create :creator => User.find(:first, :order => randomize),
                :starts_at => start,
                :ends_at => start + ((3..5).to_a.rand * 15).minutes,
                :account => account,
                :name => "#{event} #{Faker::Name.name}",
                :tag_names => ['dewey', 'food', 'Seattle', 'Tacoma', 'RJC', 'OP', 'courtdate-tag'].rand
  end
  rand(2).times do
   event = ["FinDec from", "payment from", "dates for", "docs to", "signature of"].rand
   Task.create :creator => User.find(:first, :order => randomize),
                :starts_at => date,
                :account => account,
                :name => "Get #{event} #{Faker::Name.name}",
                :tag_names => ['dewey', 'food', 'Seattle', 'Tacoma', 'RJC', 'OP', 'task-tag'].rand
  end
 
  rand(2).times do
    start = date.beginning_of_day + 8.hours + (rand(32) * 15).minutes
    event = ["File docs", "Statute of Limitations", "Response due", "OA's Response due", "discovery cutoff"].rand
   Deadline.create :creator => User.find(:first, :order => randomize),
                    :starts_at => start,
                    :account => account,
                    :name => "#{event} for #{Faker::Name.name}", 
                    :tag_names => ['dewey', 'food', 'Seattle', 'Tacoma', 'RJC', 'OP', 'deadline-tag'].rand
 end
  
end