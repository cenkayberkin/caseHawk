namespace :calendar do
  desc 'Send event reminders. Should be ran once per minute, every minute.'
  task :remind, :needs => :environment do
    for user in User.active
      for event in Event.for_account(user.account.id).with_tags(user.login).find(:all, 
        :conditions => ["type != 'AllDay' AND type != 'Task' " + 
          "AND completed_at IS NULL " + 
          "AND starts_at LIKE ? " + 
          "AND remind = 1", "#{45.minutes.from_now.to_s(:ymdhs)}%"])
        
        puts "Found event #{event.id} tagged with #{user.login}. Sending reminder..."
        CalendarNotifier.deliver_reminder(user, event)
      end
    end
  end
end