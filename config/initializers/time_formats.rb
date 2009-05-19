# Be sure to restart your server when you modify this file.

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :us => '%m/%d/%y',
  :us_with_time => '%m/%d/%y, %l:%M %p',
  :short_day => '%e %B %Y',
  :long_day => '%A, %e %B %Y',
  :year => '%Y',
  :friendly => proc { |time|
    if time.year == Time.now.year
      time.strftime "%b #{time.day.ordinalize}"
    else
      time.strftime "%b #{time.day.ordinalize}, %Y"
    end
  }
)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :simple => proc { |time| 
    time.strftime('%l:%M%p').downcase
  }
)
