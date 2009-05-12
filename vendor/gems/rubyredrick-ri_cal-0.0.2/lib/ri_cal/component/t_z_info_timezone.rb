#- ©2009 Rick DeNatale
#- All rights reserved. Refer to the file README.txt for the license
#
# A wrapper class for a Timezone implemented by the TZInfo Gem
# (or by Rails)
class RiCal::Component::TZInfoTimezone < RiCal::Component::Timezone

  class Period #:nodoc: all

    def initialize(which, this_period, prev_period)
      @which = which
      @onset = this_period.local_start.strftime("%Y%m%dT%H%M%S")
      @offset_from = format_rfc2445_offset(prev_period.utc_total_offset)
      @offset_to = format_rfc2445_offset(this_period.utc_total_offset)
      @abbreviation = this_period.abbreviation
      @rdates = []
    end

    def add_period(this_period)
      @rdates << this_period.local_start.strftime("%Y%m%dT%H%M%S")
    end


    def format_rfc2445_offset(seconds) #:nodoc:
      abs_seconds = seconds.abs
      h = (abs_seconds/3600).floor
      m = (abs_seconds - (h * 3600))/60
      h *= -1 if seconds < 0
      sprintf("%+03d%02d", h, m)
    end

    def export_to(export_stream)
      export_stream.puts "BEGIN:#{@which}"
      export_stream.puts "DTSTART:#{@onset}"
      export_stream.puts "RDATE:#{@rdates.join(",")}"
      export_stream.puts "TZOFFSETFROM:#{@offset_from}"
      export_stream.puts "TZOFFSETTO:#{@offset_to}"
      export_stream.puts "TZNAME:#{@abbreviation}"
      export_stream.puts "END:#{@which}"
    end
  end

  class Periods #:nodoc: all

    def initialize
      @dst_period = @std_period = @previous_period = nil
    end

    def daylight_period(this_period, previous_period)
      @daylight_period ||= Period.new("DAYLIGHT", this_period, previous_period)
    end

    def standard_period(this_period, previous_period)
      @standard_period ||= Period.new("STANDARD", this_period, previous_period)
    end

    def log_period(period)
      @periods ||= []
      @periods << period unless @periods.include?(period)
    end

    def add_period(this_period)
      if @previous_period
        if this_period.dst?
          period = daylight_period(this_period, @previous_period)
        else
          period = standard_period(this_period, @previous_period)
        end
        period.add_period(this_period)
        log_period(period)
      end
      @previous_period = this_period
    end

    def export_to(export_stream)
      @periods.each {|period| period.export_to(export_stream)}
    end
  end

  attr_reader :tzinfo_timezone #:nodoc:

  def initialize(tzinfo_timezone) #:nodoc:
    @tzinfo_timezone = tzinfo_timezone
  end

  # convert time from this time zone to utc time
  def local_to_utc(time)
    @tzinfo_timezone.local_to_utc(time.to_ri_cal_ruby_value)
  end

  # convert time from utc time to this time zone
  def utc_to_local(time)
    @tzinfo_timezone.utc_to_local(time.to_ri_cal_ruby_value)
  end

  # return the time zone identifier
  def identifier
    @tzinfo_timezone.identifier
  end

  def export_local_to(export_stream, local_start, local_end) #:nodoc:
    export_utc_to(export_stream, local_to_utc(local_start.to_ri_cal_ruby_value), local_to_utc(local_end.to_ri_cal_ruby_value))
  end

  def to_rfc2445_string(utc_start, utc_end) #:nodoc:
    export_stream = StringIO.new
    export_utc_to(export_stream, utc_start, utc_end)
    export_stream.string
  end

  def export_utc_to(export_stream, utc_start, utc_end) #:nodoc:
    export_stream.puts "BEGIN:VTIMEZONE","TZID;X-RICAL-TZSOURCE=TZINFO:#{identifier}"
    periods = Periods.new
    period = tzinfo_timezone.period_for_utc(utc_start)
     #start with the period before the one containing utc_start
    period = tzinfo_timezone.period_for_utc(period.utc_start - 1)
    while period && period.utc_start < utc_end
      periods.add_period(period)
      period = tzinfo_timezone.period_for_utc(period.utc_end + 1)
    end
    periods.export_to(export_stream)
    export_stream.puts "END:VTIMEZONE\n"
  end
end