# == Schema Information
#
# Table name: events
#
#  id           :integer(4)      not null, primary key
#  account_id   :integer(4)      not null
#  creator_id   :integer(4)      not null
#  owner_id     :integer(4)
#  type         :string(255)     not null
#  name         :string(255)     not null
#  remind       :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#  completed_at :datetime
#  starts_at    :datetime
#  ends_at      :datetime
#  location_id  :integer(4)
#  completed_by :integer(4)
#  version      :integer(4)
#  deleted_at   :datetime
#

class CourtDate < Appointment
  before_save :enforce_single_day
  
  def enforce_single_day
    self.ends_at_date = starts_at_date if starts_at_date != ends_at_date
  end
  
  def timed?
    true
  end
  
  def to_html_attributes
    super.merge(
      {
        "data-starts-at-time" => starts_at_time,
        "data-ends-at"        => ends_at,
        "data-ends-at_time"   => ends_at_time,
      })
  end
end
