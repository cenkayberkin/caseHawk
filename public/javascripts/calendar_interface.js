$(function(){

  // Let the user know the event details can slide out
  // by giving them a 'pointer' cursor.
  // Slide in/out of view the event's details
  // when the user clicks an event
  $(".event-details").hide()
  $(".event-title")
    .addClass("clickable")
    .click(function(){
      var detail = $(this).next(".event-details")
      // hide any (other) open detail elements
      $(".event-details").filter(function(){
        return this != detail[0]
      }).fadeOut()
      // show/hide the appropriate detail element
      detail.toggle('normal')
    })

  // When the user mouses over an event that spans a period of time
  // the timeslot on the left side of the calendar should highlight
  $(".appointment").hover(
    function() {
      e = Event.instantiate(this)
      // Treat time parts as string for concatenation with +
      hour = "" + e.start.getHours()
      min = e.start.getMinutes() == 0 ? "00" : "" + e.start.getMinutes()
      endStamp = "" + e.end.getHours() + (e.end.getMinutes() == 0 ? "00" : e.end.getMinutes())
      // Start highlighting the timeline at the appt start time
      $("#timerow-" + hour + min).css("background-color","#e3e6f9")
      while (hour + min != endStamp && hour + min != "2400") {
        // And keep highlighting until we reach the end time.
        $("#timerow-" + hour + min).css("background-color","#e3e6f9")
        if (min == "45") {
          hour = "" + (parseInt(hour) + 1)
          min = "00"
        }
        else {
          min = "" + (parseInt(min) + 15)
        }
      } 
    },
    function(){
      $('.hourslice').css("background-color", "white")
    }
  )

  // support ajax completion of completable events
  $(".day-deadlines, .sidebar-tasks")
    .find("li.event input[type=checkbox]")
    .click(function(){
      var li = $(this).parents("li.event")
      Event.update(li,
                   {'event[completed]': li.hasClass('incomplete') ? '1' : ''},
                   function(event){
                     li.removeClass('complete incomplete')
                     li.addClass(event.completed_at ? 'complete' : 'incomplete')
                   })
    })
})

