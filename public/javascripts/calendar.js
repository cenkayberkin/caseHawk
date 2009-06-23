// Interface:
//
//  Calendar.drawAllWeeks # draws the top five weeks
//  Calendar.drawWeek(4)
//    # makes sure the 5th week from the top is available
//    # calls via callback:
//    Calendar.placeWeekEvent
//  Calendar.prepEvents
//    # sets up events for toggling the details callout
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
  $(".week").each(Calendar.initWeek)
})

Calendar = {
  initDay: function(){
    Calendar.positionEvents()
    Calendar.adjustViewport()
    Calendar.boxDayEvents()
    Calendar.prepEvents()
  },
  initWeek: function(){
    Calendar.prepEvents()
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
    // draw the event on the page
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
  positionEvents: function(element){
    $(element ?
        element :
        ".day-appointments .event, .day-deadlines .event"
      )
      .each(function(){
        var e = Event.instantiate(this)
        $(this)
          .css({
            top: 60 * e.start.getHours()
                    + e.start.getMinutes(),
            height: Calendar.heightInPixels(
                      e.end && e.start ? e.end - e.start : 0
                    )+'px'
          })
      })
  },
  adjustViewport: function(){
    var events =
          $(".day-wrapper .event, .day-wrapper .collision_box")
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
    debug(start_px)
    debug(end_px)
    $(".day-hours, .day-full").css({
      "margin-top":
        "-"
        + start_px
        +"px",
      "height":
        end_px +'px'
    })
  },
  heightInPixels: function(durationInMilliSeconds){
    return durationInMilliSeconds > 0 ?
              ((durationInMilliSeconds/1000)/60) : 15
  },
  prepEvents: function(){
    $(".event-details").hide()
    $(".event-title").addClass("clickable")
  },
  // Sort all the events and find ones that are touching
  // For each pair of adjacent events call Calendar.Box()
  // with the two events as arguments.
  boxDayEvents: function(){
    var events = $(".day-appointments .event")
                  .map(function(){
                    return Event.instantiate(this)
                  })
                  .sort(function(a,b){
                    return a.starts_at > b.starts_at ? 1 : -1
                  })
                  .map(function(){return this})
    $.each(events, function(idx, event){
      (events[idx+1] && events[idx+1].start <= event.end) &&
        Calendar.Box(event, events[idx+1])
    })
    Calendar.Box.arrange()
  },
  // function Box(a, b)
  //  Combine two events at a time into a box.
  //  If event A is already in a box then add
  //  event B to the existing box (and vice versa)
  //  this will store an array of arrays representing
  //  an array of boxes of events.
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
            box.push(b)
            found = true
          }
          if(cell == b){
            box.push(a)
            found = true
          }
        })
      })
      if(!found)
        boxes.push([a, b])
    }
    boxFn.arrange = function(){
      $.each(boxes, function(_,box){
        var holder = $("<div class='collision_box'></div>")
        holder.css({
          top:    $(box[0]).css("top"),
          height: Calendar.heightInPixels(
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
        holder.appendTo($("ul.day-appointments"))
      })
    }
    return boxFn
  }()
}