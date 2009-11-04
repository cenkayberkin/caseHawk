namespace :calendar do
  desc 'Send event reminders'
  task :remind, :needs => :environment do
    for event in Event.find(:all, 
      :conditions => "type != 'AllDay'",
      :conditions => "starts_at < NOW()",
      :conditions => ["starts_at > ? ", 18.hours.ago.to_s(:db)],
      :conditions => "remind = 1")
      
      for user in event.tag_records.map{ |t| User.find_by_login(t.name) }.compact
        puts "Found event #{event.id} tagged with #{user.login}. Sending reminder..."
        CalendarNotifier.deliver_reminder(user, event)
        event.remind = false
        event.save
      end
    end
  end
end