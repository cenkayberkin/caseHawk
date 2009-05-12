class CalendarsController < ApplicationController

  def index
  end

  def show
    render :text =>  RiCal.Calendar do |cal|
      cal.event do |event|
        event.description = "MA-6 First US Manned Spaceflight"
        event.dtstart =  DateTime.parse("2/20/1962 14:47:39")
        event.dtend = DateTime.parse("2/20/1962 19:43:02")
        event.location = "Cape Canaveral"
        event.add_attendee "john.glenn@nasa.gov"
        event.alarm do
          description "Segment 51"
        end
      end
    end
  end
end
