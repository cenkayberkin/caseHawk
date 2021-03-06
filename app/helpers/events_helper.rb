module EventsHelper
  
  # Use these methods to get events of a certain type: get_tasks(@events) 
  
  def get_type(records, type)
    records.select { |r| r.class == type }
  end
  
  def get_tasks(records)
    get_type(records, Task)
  end
  
  def get_appointments(records)
    get_type(records, Appointment)
  end
  
  def get_court_dates(records)
    get_type(records, CourtDate)
  end
  
  def get_deadlines(records)
    get_type(records, Deadline)
  end
  
  def get_all_days(records)
    get_type(records, AllDay)
  end
  
  def get_timed_events(records)
    get_deadlines(records) + get_appointments(records) + get_court_dates(records)
  end
  
  # Return array of all the event types we are using
  def event_types
    %w[AllDay Appointment CourtDate Deadline Task]
  end
  
  # Methods to build the event items on the calendar
  def conditional_checkbox(event)
    event.completable? ?
      (check_box_tag event.id, 
        '1', 
        event.completed_at, 
        :id => "event-complete-#{event.id}", 
        :class => 'task checkbox', 
        :name => event.id) :
      ""
  end
  
  def event_line_html(event)
    title =  "#{event.timed? ? l(event.starts_at, :format => :simple) + 
      (event.ends_at_time.blank? ? "" : "&#8212;" + 
      l(event.ends_at, :format => :simple)) : ""}: #{event.name}" +
      event_tags(event)
    conditional_checkbox(event) +
    link_to(event_line_text(event), 
      event_path(event), 
      { :class => "event-title", 
        :title => title })
  end
  
  def agenda_event_line_html(event)
    title =  "#{event.timed? ? l(event.starts_at, :format =>:simple) + 
      (event.ends_at_time.blank? ? "" : "&#8212;" + 
      l(event.ends_at, :format => :simple)) : ""} #{event.name}" +
      event_tags(event)
    conditional_checkbox(event) +
    link_to(agenda_event_line_text(event), 
      event_path(event), 
      { :class => "event-title", 
        :title => title })   
  end
  
  def event_line_text(event)
    if event.timed?
      content_tag :span, l(event.starts_at, :format => :simple) + " ", { :class => "time" }
    end.to_s +
    event.name +
    event_tags(event)
  end
  
  def agenda_event_line_text(event)
    (content_tag :span, l(event.starts_at.to_date, :format =>:us_short) + " ", { :class => "date" }).to_s + 
    if event.timed?
      content_tag :span, l(event.starts_at, :format =>:simple) + " ", { :class => "time" }
    end.to_s +
    event.name  
  end
  
  def event_tags(event)
    "#{event.tags.blank? ? "" : " - " + event.tag_records.map(&:name).join(', ')}"
  end

end
