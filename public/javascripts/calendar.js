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
  $("#day").each(Calendar.initDay)
  $("#week").each(Calendar.initWeek)
})

Calendar = {
  initDay: function(){
    Calendar.positionEvents()
    Calendar.adjustViewport()
    Calendar.boxDayEvents()
  },
  initWeek: function(){
    Calendar.positionEvents()
    Calendar.adjustViewport()
    Calendar.boxDayEvents()
    Calendar.fixCongestedBoxes()
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
    // TODO: remove redundancy between this
    //       and Event.instantiate
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
  // attach the appropriate 'height' and 'top'
  // to the event given or (if none given)
  // to all appointments and deadlines on the page
  positionEvents: function(element){
    $(element ?
        element :
        ".viewport .event"
      )
      .each(function(){
        var e = Event.instantiate(this)
        $(this)
          .css({
            top: Calendar.top(e)+'px',
            height: Calendar.height(e)+'px'
          })
      })
  },
  // Trim the top and bottom off of the calendar
  // to hide the blank space.
  adjustViewport: function(){
    var events =
          $(".viewport .event, .viewport .collision_box")
            .map(function(){return Event.instantiate(this)})
    var earliest = 
          events.sort(function(a, b){
            return a.starts_at > b.starts_at ? 1 : -1
          })[0]
    var latest = 
          events.sort(function(a, b){
            return (a.ends_at || a.starts_at + (60*1000)) <
                   (b.ends_at || b.starts_at + (60*1000))
                      ? 1 : -1
          })[0]

    // set an approximate end time if the last event has none
    if(latest)
      latest.end || (latest.end = new Date((latest.start-0) + (60*1000)))

    var start_px = Math.min(
                     earliest ?
                       parseInt($(earliest).css("top")) : 100000000 ,
                     8*60 // 8:00 am
                   ) -30
    var end_px   = Math.max(
                     latest ?
                       latest.end.getHours()*60 + latest.end.getMinutes()
                       : 0,
                     17*60 // 5:00 pm
                   ) +30
    $(".day-hours, .day-full").css({
      "margin-top":
        "-"
        + start_px
        +"px",
      "height":
        end_px +'px'
    })
  },
  // Sort all the events and find ones that are touching
  // For each pair of adjacent events call Calendar.Box()
  // with the two events as arguments.
  boxDayEvents: function(){
    // for each element with the .collidable class
    $(".collidable").each(function(){
        // consider this element to be a list of events
        var eventList = $(this)
        // for each event in this list
        var events = eventList
              .find(".event")
              // make this into an array of Event instances
              .map(function(){
                return Event.instantiate(this)
              })
              // arrange them by start time (ascending)
              .sort(function(a,b){
                return a.starts_at > b.starts_at ? 1 : -1
              })
              .map(function(){return this})
        // for each of these events
        $.each(events, function(idx, event){
          // box this event with the one that comes right after it
          // if the next one begins before this one ends
          if((events[idx+1] && events[idx+1].start <= event.end))
            Calendar.Box(event, events[idx+1])
          // or just put it in a box by itself
          else
            Calendar.Box(event)
        })
        // place all these boxes into the .collidable
        Calendar.Box.arrange(eventList)
      }
    )
  },
  // Some collision boxes may have too many events
  // in them for their time frame.  In this case replace
  // the bottom two lines with a link that displays
  // the events better
  fixCongestedBoxes : function(){
    $(".collision_box").each(function(_,box){
      var canFit = parseInt($(box).height() / 15)
      var total  = $(box).find(".event").length
      debug("canFit :"+canFit+", total:"+total+", for", box)
      if(canFit < total){
        $(box)
          // hide everything that doesn't fit
          .find(".event")
            .slice(canFit-1, total)
              .hide()
              .end()
            .end()
          // add a little "there's more!" link
          .append(
            $("<li></li>")
              .addClass("overflow")
              .append(
                $("<a></a>")
                  .html(
                    canFit == 1 ?
                      (total)+" events &raquo;" :
                      (total-canFit+1)+" more &raquo;"
                  )
                  // which, when clicked, shows the rest of the stuff
                  .click(function(){
                    $(this)
                      .parents(".collision_box")
                        .css({height: 'auto'})
                        .find(".event")
                          .show()
                          .end()
                        .end()
                      // and hide the link
                      .hide()
                    return false
                  })
              )
          )
      }
    })
  },
  // function Box(a, b)
  //  Combine two events at a time into a box.
  //  If event A is already in a box then add
  //  event B to the existing box (and vice versa)
  //  this will store an array of arrays representing
  //  an array of boxes of events.
  //  if B wasn't provided then just check that A isn't
  //  boxed yet and put it by itself
  // function Box.arrange()
  //  draw each box based on the start time of the
  //  earliest event and the end time of the latest.
  Box: function(){
    var boxes = []
    var boxFn = function(a, b){
      var found = false
      $.each(boxes, function(_, box){
        $.each(box, function(_, cell){
          if(cell == a){
            if(b) box.push(b)
            found = true
          }
          if(cell == b){
            box.push(a)
            found = true
          }
        })
      })
      if(!found)
        if(b)
          boxes.push([a, b])
        else
          boxes.push([a])
    }
    boxFn.arrange = function(eventList){
      $.each(boxes, function(_,box){
        var holder = $("<div class='collision_box'></div>")
        holder.css({
          top:    $(box[0]).css("top"),
          height: Calendar.timeDifferentInPixels(
                      box[box.length-1].end && box[0].start ?
                        box[box.length-1].end - box[0].start : 0
                    )+'px'
        })
        $.each(box, function(_,e){
          $(e)
            .css(
              { height:   'auto',
                position: 'relative',
                top:      '0px'
              })
            .appendTo(holder)
        })
        holder.appendTo(eventList)
      })
      // and clear the boxes
      boxes = []
    }
    return boxFn
  }(),


  // determine the number of pixels between the start
  // of the calendar and the event start time
  top: function(event){
    var e = Event.instantiate(event)
    return 60 * e.start.getHours() + e.start.getMinutes()
  },
  // determine the number of pixels required to draw the event's height
  height: function(event){
    var e = Event.instantiate(event)
    return Calendar.timeDifferentInPixels(
                      e.end && e.start ? e.end - e.start : 0
                    )
  },
  // given the difference between two times return the number
  // of pixels that should be used to represent the interval
  timeDifferentInPixels: function(durationInMilliSeconds){
    return durationInMilliSeconds > 0 ?
              ((durationInMilliSeconds/1000)/60) : 15
  },
}