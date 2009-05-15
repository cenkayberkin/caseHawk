// 
// Calendar = {tags: ''}
// 
// $.extend(Calendar, {
//   url: function(){
//     this.tags == '' ?
//       '/calendar/' :
//       '/tags/'+this.tags+'/calendar'
//   },
//   retrieve: function(weeks_ago){
//     $.get(this.url(),
//           {weeks_ago: weeks_ago || 0},
//           function(content){
//             console.log(content)
//           })
//   }
// })
// 

// Interface:
//
//  Calendar.drawAlllWeeks # draws the top five weeks
//  Calendar.drawWeek(4)
//    # makes sure the 5th week from the top is available
//    # calls:
//    Calendar.loadWeekEvents(4)
//      # retrieves and instantiates all events for the 5th week from top
//  Calendar.drawDay('2009-05-01')
//    # loads and places all events on the given day
//    # calls:
//    Calendar.loadDayEvents('2009-05-01')
//      # retrieves and instantiates all events for the given day
//    Calendar.loadDayEvents('2009-05-01', {tags: ["one", "two"]})
//      # limited to tags
//    Calendar.placeDayEvents('2009-05-01')
//      # calculates positions for each event in the current day calendar
//      # adds height according to time length
//    Calendar.boxDayEvents('2009-05-01')
//      # finds intersecting events and groups them into a single event list

Calendar = {
  drawAllWeeks: function(){},
  drawWeek: function(){},
  drawDay: function(){},
  loadDayEvents: function(){},
  placeDayEvents: function(){},
  boxDayEvents: function(){}
}