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
//      # calls:
//      Calendar.adjustViewport()
//        # hides the portion of the day where no events are scheduled
//    Calendar.boxDayEvents('2009-05-01')
//      # finds intersecting events and groups them into a single event list

$(function(){
  // if there's a #day then this is a single-day page
  $("#day").each(Day.init)
  // load the first week
  Week.loadFirst()
  // initialize each week on the page
  $("table.week-events").each(Calendar.initWeek)
})

Calendar = {
  initWeek: function(_, week){
    Day.positionEvents()
    Week.adjustViewport(week)
    Day.boxDayEvents()
    Day.fixCongestedBoxes()
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


}