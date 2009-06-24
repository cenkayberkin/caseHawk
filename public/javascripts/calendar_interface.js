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
    function(){
      e = Event.instantiate(this)
      // Treat time parts as string for concatenation with +
      hour = "" + e.start.getHours()
      min = e.start.getMinutes() == 0 ? "00" : "" + e.start.getMinutes()
      endStamp = "" +e.end.getHours() + (e.end.getMinutes() == 0 ? "00" : e.end.getMinutes())
      do {
        $("#timerow-" + hour + min).css("background-color","yellow")
        if (min == "45") {
          hour = "" + (parseInt(hour) + 1)
          min = "00"
        }
        else {
          min = "" + (parseInt(min) + 15)
        }
      } while (hour + min != endStamp && hour + min != "2400")
    },
    function(){
      $('.hourslice').css("background-color", "white")
    }
  )
})
