// Interface:
//
//  Calendar.drawAllWeeks # draws the top five weeks
//  Calendar.drawWeek(4)
//    # makes sure the 5th week from the top is available
//    # calls via callback:
//    Calendar.placeWeekEvent
//  Calendar.drawDay('2009-05-01')
//    # loads and places all events on the given day
//    # calls via callback:
//    Calendar.placeDayEvents('2009-05-01')
//      # calculates positions for each event in the current day calendar
//      # adds height according to time length
//    Calendar.boxDayEvents('2009-05-01')
//      # finds intersecting events and groups them into a single event list

$(function(){
  $("#day").each(Calendar.initDay)
  $("#week").each(Calendar.initWeek)
})

Calendar = {
  initDay: function(){
    Calendar.positionEvents()
  },
  initWeek: function(){
  },
  drawAllWeeks: function(){
    for(i=0;i<5;i++)
      Calendar.drawWeek(i)
  },
  drawWeek: function(week){
    Event.find({week: week}, function(event){
      Calendar.placeWeekEvent(event)
    })
  },
  placeWeekEvent: function(event){
    // draw the event on the page
  },
  drawDay: function(date, options){
    Event.find(
      $.extend({start_date: date, end_date: date}, options),
      function(event){ Calendar.placeDayEvent(event) }
    )
  },
  placeDayEvent: function(event){
    // draw the event on the page
    var element =
      $("<li></li>")
        .attr({
          "data-event-id":  event.id,
          "data-start":     event.start,
          "data-end":       event.end
        })
        .addClass("event")
        .addClass(event.type.underscore())
        .html(event.display())
        .appendTo("ul.day-appointments")
    Calendar.positionEvents(element)
  },
  positionEvents: function(element){
    $(element ?
        element :
        ".day-appointments .event, .day-deadlines .event"
      )
      .each(function(){
        $(this)
          .css({
            top: 60 * Event.instantiate(this).start.getHours()
          })
      })
  },
  boxDayEvents: function(){
    // group adjacent events into boxes
  }
}