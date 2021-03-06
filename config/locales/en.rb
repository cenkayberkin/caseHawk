{
  en: {
    date: {
      formats: {
        us: "%m/%d/%y",
        us_with_time: "%m/%d/%y, %l:%M %p",
        us_long_year: "%m/%d/%Y", 
        us_short: "%b %e %Y",
        short_day: "%e %B %Y",
        short_day_month_first: "%B %e, %Y", 
        long_day: "%A, %e %B %Y",
        long_day_month_first: "%A, %B %e, %Y", 
        year: "%Y",
        yw: "%Y-w%U",
        md: "%b %e",
        full: "%B %e, %Y %H:%M",
        mdth: proc { |time|
          if time.year == Time.now.year
            time.strftime "%b #{time.day.ordinalize}"
          else
            time.strftime "%b #{time.day.ordinalize}, %Y"
          end
        },
        Mdth: proc { |time|
          if time.year == Time.now.year
            time.strftime "%B #{time.day.ordinalize}"
          else
            time.strftime "%B #{time.day.ordinalize}, %Y"
          end
        }
      }
    },

    time: {
      formats: {
        yw: "%Y-w%U",
        mdhm: proc { |time| 
          time.strftime("%M") == "00" ? 
            time.strftime("%b %e, %l%p").downcase.chop :
            time.strftime("%b %e, %l:%M%p").downcase.chop
        },
        full_time: "%l:%M %p", 
        simple: proc { |time| 
          time.strftime("%M") == "00" ? 
            time.strftime("%l%p").downcase.chop :
            time.strftime("%l:%M%p").downcase.chop
        },
        hmmdth: proc { |time| 
          if time.year == Time.now.year
            day = time.strftime "%b #{time.day.ordinalize}"
          else
            day = time.strftime "%b #{time.day.ordinalize}, %Y"
          end
          time.strftime("%M") == "00" ? 
            time.strftime("%l%p").downcase.chop + " " + day :
            time.strftime("%l:%M%p").downcase.chop + " " + day
        },
        md: "%b %e",
        full: "%B %e, %Y %H:%M",
        mdth: proc { |time|
          if time.year == Time.now.year
            time.strftime "%b #{time.day.ordinalize}"
          else
            time.strftime "%b #{time.day.ordinalize}, %Y"
          end
        },
        Mdth: proc { |time|
          if time.year == Time.now.year
            time.strftime "%B #{time.day.ordinalize}"
          else
            time.strftime "%B #{time.day.ordinalize}, %Y"
          end
        },
        ymdhs: "%Y-%m-%d %H:%M"
      }
    }
  }
}
