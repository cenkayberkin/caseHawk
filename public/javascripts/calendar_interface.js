$(function(){

  // Let the user know the event details can slide out
  // by giving them a 'pointer' cursor.
  // Slide in/out of view the event's details
  // when the user clicks an event
  $(".event-details").hide()

  // When the user mouses over an event that spans a period of time
  // the timeslot on the left side of the calendar should highlight
  $(".collidable .event").hover(
    function() {
      e = Event.instantiate(this)
      // Treat time parts as string for concatenation with +
      year = "" + e.start.getFullYear()
      week = "" + e.start.getWeek()
      hour = "" + e.start.getHours()
      min = e.start.getMinutes() == 0 ? "00" : "" + e.start.getMinutes()
      //alert("Coloring: " + "#" + year + "-w" + week + "-timerow-" + hour + min)
      endStamp = "" + e.end.getHours() + (e.end.getMinutes() == 0 ? "00" : e.end.getMinutes())
      // Start highlighting the timeline at the appt start time
      $("#" + year + "-w" + week + "-timerow-" + hour + min).css("background-color","#e3e6f9")
      while (hour + min != endStamp && hour + min != "2400") {
        // And keep highlighting until we reachthe end time.
        $("#" + year + "-w" + week + "-timerow-" + hour + min).css("background-color","#e3e6f9")
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
  $("li.event_completable input[type=checkbox]")
    .click(function(){
      var checkbox = $(this)
      var li = checkbox.parents("li.event_completable")
      Event.update(li,
                   {completed: li.hasClass('incomplete') ? '1' : ''},
                   function(event){
                     li.removeClass('complete incomplete')
                     li.addClass(event.completed_at ? 'complete' : 'incomplete')
                   })
      // if there are multiple checkboxes make sure they all
      // have the same state as this one
      li.find("input[type=checkbox]").each(function(){
        $(this).attr('checked', checkbox.attr('checked'))
      })
    })
  
  $("li.event").each(function(){
    var event = Event.instantiate($(this))
    $(this)
      .find('.editable')
      .each(function(){
        var editable = $(this)
        editable.editable(
          event.url,
          { name        : "event["+editable.attr("data-field-name")+"]",
            tooltip     : 'Click to Edit',
            submitdata  : {"_method": "PUT"},
            ajaxoptions : {dataType: 'json'},
            callback    : function(savedEvent){
              // using the actual saved value
              // in the input field
              $(this).html(
                savedEvent[editable.attr("data-field-name")]
              )
            }
          }
        )
      })
  })
  
  $('a[rel*=facebox]').facebox()
})

