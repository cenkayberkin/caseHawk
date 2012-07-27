class Appointment < Event

  before_save :enforce_single_day
  
  def enforce_single_day
    self.ends_at_date = starts_at_date if starts_at_date != ends_at_date
  end
  
  def timed?
    true
  end

end
