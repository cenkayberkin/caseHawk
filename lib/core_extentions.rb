class Date
  def beginning_of_week
    self - self.wday.days
  end
  
  def end_of_week
    self + ((6 - self.wday)).days
  end
end