// Interface:
//
//  Calendar.drawAlllWeeks # draws the top five weeks
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

Calendar = {
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
    console.debug(event)
  },
  drawDay: function(date, options){
    Event.find(
      $.extend({start_date: date, end_date: date}, options),
      function(event){ Calendar.placeDayEvent(event) }
    )
  },
  placeDayEvent: function(event){
    // draw the event on the page
    console.debug(event)
  },
  boxDayEvents: function(){
    // group adjacent events into boxes
  }
}