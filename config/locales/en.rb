{
  en: {
    date: {
      us_short: '%b %e %Y'
    },

    time: {
      formats: {
        simple: proc { |time| 
          time.strftime('%M') == '00' ? 
          time.strftime('%l%p').downcase.chop :
          time.strftime('%l:%M%p').downcase.chop
        }
      }
    }
  }
}
