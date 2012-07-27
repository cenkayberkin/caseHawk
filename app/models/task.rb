class Task < Event
  before_save :enforce_nil_end_date
  
  def enforce_nil_end_date
    self.ends_at = nil
  end

  def completable?
    true
  end
end
