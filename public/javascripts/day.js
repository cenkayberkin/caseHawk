

Day = {
  init: function(day){
    Day.positionEvents($(day).find(".viewport .event"))
    Day.boxDayEvents($(day))
    Day.fixCongestedBoxes($(day))
  },
  drawDay: function(date, options){
    Event.find(
      $.extend({start_date: date, end_date: date}, options),
      function(event){ Day.placeDayEvent(event) }
    )
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
            top: Day.top(e)+'px',
            height: Day.height(e)+'px'
          })
      })
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
    Day.positionEvents(element)
  },
   // Sort all the events and find ones that are touching
  // For each pair of adjacent events call Calendar.Box()
  // with the two events as arguments.
  boxDayEvents: function(day){
    // for each element with the .collidable class
    day.find(".collidable").each(function(){
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
                return a.starts_at == b.starts_at ?
                         (a.ends_at   < b.ends_at   ? 1 : -1) :
                         (a.starts_at > b.starts_at ? 1 : -1)
              })
              .map(function(){return this})

        var latestEventSoFar = events.length && events[0]
        // for each of these events
        $.each(events, function(idx, event){
          // box this event with the ones adjacent and
          // overlapping with it
          if(latestEventSoFar.end >= event.start)
            Day.Box(latestEventSoFar, event)
          // or just put it in a box by itself
          else
            Day.Box(event)

          if(latestEventSoFar.end < event.end)
            latestEventSoFar = event
        })
        // place all these boxes into the .collidable
        Day.Box.arrange(eventList)
      }
    )
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
          height: Day.timeDifferentInPixels(
                      Day.lastEnd(box) - Day.firstStart(box)
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
  // Some collision boxes may have too many events
  // in them for their time frame.  In this case replace
  // the bottom two lines with a link that displays
  // the events better
  fixCongestedBoxes : function(day){
    day.find(".collision_box").each(function(_,box){
      var canFit = parseInt($(box).height() / 15)
      var total  = $(box).find(".event").length
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
              .addClass("event-overflow")
              .addClass("overflow")
              .append(
                $("<a></a>")
                  .html(
                    canFit == 1 ?
                      (total)+" events &raquo;" :
                      (total-canFit+1)+" more &raquo;"
                  )
                  // which, when clicked, shows the rest of the events
                  .click(function(){
                    $(this)
                      .parents(".collision_box")
                        .css({height: 'auto'})
                        .addClass("collision_box_overflow")
                        .find(".event")
                          .show()
                          .end()
                        .end()
                      // and hides itself
                      .hide()
                    return false
                  })
              )
          )
      }
    })
  },
  // determine the number of pixels between the start
  // of the calendar and the event start time
  top: function(event){
    var e = Event.instantiate(event)
    return 60 * e.start.getHours() + e.start.getMinutes()
  },
  // determine the number of pixels required to draw the event's height
  height: function(event){
    var e = Event.instantiate(event)
    return Day.timeDifferentInPixels(
                      e.end && e.start ? e.end - e.start : 0
                    )
  },
  // find the earliest that any of the given events starts
  firstStart: function(events){
    return Math.min.apply(null,
                          $.map(events, function(e){
                                          var event = Event.instantiate(e)
                                          return e.start ? +e.start : 999999999999
                                        }))
  },
  // find the latest that any of the given events lasts
  lastEnd: function(events){
    return Math.max.apply(null,
                          $.map(events, function(e){
                                          var event = Event.instantiate(e)
                                          return e.end ? +e.end : 0
                                        }))
  },
  // given the difference between two times return the number
  // of pixels that should be used to represent the interval
  timeDifferentInPixels: function(durationInMilliSeconds){
    return durationInMilliSeconds > 0 ?
              ((durationInMilliSeconds/1000)/60) : 15
  }
}