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
  
  # Return array of all the event types we are using
  def event_types
    %w[AllDay Appointment CourtDate Deadline Task]
  end
end
