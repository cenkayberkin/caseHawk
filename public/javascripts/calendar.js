
$(function(){
  // if there's a #day then this is a single-day page
  $("#day").each(Day.init)
  // load the first week
  Week.loadFirst()
  // initialize each week on the page
  $("table.week-events").each(Week.init)
})

Calendar = {}