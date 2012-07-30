

Day = {
  allday: function(day){
    return day.is(".week-allday .day")
  },
  timed: function(day){
    return day.is(".week-day-full .day")
  },

  init: function(day){
    if(0 == day.length) return

    if(Day.timed(day)){
      Day.clearBoxes(day)
      Day.positionEvents(day.find(".event"))
      Day.boxDayEvents(day)
      Day.fixCongestedBoxes(day)
    }
    Day.clicks(day)
  },

  refresh: function(day){
    Day.init(day)
    if(Day.timed(day)){
      // remove stray, duplicate, non-boxed events
      day.find(".collidable > .event").remove()
      Week.adjustViewport(day.parents(".week"))
    }
  },

  // remove any collision boxes previously added by boxDayEvents
  clearBoxes: function(day){
    var collidable = day.find(".collidable")
    collidable.html(
      day.find(".event")
    )
    // day.find(".event").appendTo(collidable)
    // day.find(".collision_box").remove()
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
        $(e)
          .css({
            top: Day.top(e)+'px',
            height: Day.height(e)+'px'
          })
      })
  },

  // Populate the add new event form and highlight it
  // *******
  clicks : function(day) {
    // set this up on both td's for the day
    var date = day.attr("data-date")
    var nice_date = new Date(date.replace(/-/g, "/")); 

    $("[data-date="+date+"]").click(function(){
      $('#new_event .editable_date').html(nice_date.strftime("%B %e, %Y")); //.effect("highlight", { color : "#d7fcd7"}, 500);
      validateEventFormDates(); 
      $('#event_name').focus();
    })
  },
  // Sort all the events and find ones that are touching
  // For each pair of adjacent events call Day.Box()
  // with the two events as arguments.
  boxDayEvents: function(day){
    Day.clearBoxes(day)
    
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
        if(   latestEventSoFar.end >= event.start
           && latestEventSoFar != event )
          Day.Box(latestEventSoFar, event)
        // or just put it in a box by itself
        else
          Day.Box(event)

        if(latestEventSoFar.end < event.end)
          latestEventSoFar = event
      })
      // place all these boxes into the .collidable
      Day.Box.arrange(eventList)
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
        var holder = $("<div class='holder'></div>")
        var container = $("<div class='collision_box'></div>")
        var boxTop = $(box[0]).css("top")
        container.css({
          top:    boxTop,
          height: Day.timeDifferentInPixels(
                      Day.lastEnd(box) - Day.firstStart(box)
                    )+'px'
        })

        // track where they last event was placed (starting at -15 pixels)
        var lastEventTop = boxTop - 15

        $.each(box, function(_,e){

          // calculate where this event *should* be placed, relative to it's box
          var top = Day.top(e) - parseInt(boxTop)
          // if there is an event in the way, move us down to the next spot
          if(top < lastEventTop + 15)
            top = lastEventTop + 15
          lastEventTop = top

          $(e)
            .css(
              { height:   'auto',
                position: 'absolute',
                top:      top+'px'
              })
            .appendTo(holder)
        })

        holder.appendTo(container)
        container.appendTo(eventList)
      })
      // and clear the boxes
      boxes = []
    }
    return boxFn
  }(),
  // Some collision boxes may have too many events
  // in them for their time frame.  In this case replace
  // the bottom line with a link that displays
  // the events better
  fixCongestedBoxes : function(day){
    day.find(".collision_box").each(function(_,box){

      var lastPosition = parseInt($(box).css('height')) - 15
      $(box).find(".event").each(function(){
        var top = parseInt($(this).css('top'))
        if( top >  lastPosition) $(this).addClass('too_late')
        if( top == lastPosition) $(this).addClass('at_the_very_end')
      })
      var tooLate = $(box).find(".event.too_late")
      // and the last one (if it exists) because we need this space for a message
      var shouldHide = $(box).find(".event.too_late, .event.at_the_very_end")

      if(tooLate.length){
        // hide everything that doesn't fit
        shouldHide.hide()
        // add a little "there's more!" link
        $(box)
          .append(
            $("<li></li>")
              .addClass("event-overflow")
              .addClass("overflow")
              .css('top', lastPosition+'px')
              .append(
                $("<a></a>")
                  .html(
                    shouldHide.length == 1 ?
                      (shouldHide.length)+" events &raquo;" :
                      (shouldHide.length)+" more &raquo;"
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