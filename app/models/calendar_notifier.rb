class CalendarNotifier < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  
  def setup_email(to, subject, from = AppConfig['from_email'])
    @sent_on = Time.now
    @subject = subject
    @recipients = to.respond_to?(:email) ? to.email : to
    @from = from.respond_to?(:email) ? from.email : from
    content_type  'text/html'
  end
  
  def welcome(account)
    setup_email(account.admin, "Welcome to #{AppConfig['app_name']}!")
    @body = { :account => account }
  end
  
  def reminder(user, event)
    setup_email(user, "[CH] Reminder: #{event.name}")
    @body = { :user => user, :event => event }
  end
  
  def event_changed
    
  end
  
  def event_attendance
    
  end
  
  def event_cancelled
    
  end

end
