Event = {
  find: function(options, callback){
    if (Number == options.constructor)
      Event.retrieve({id: options}, callback)
    else
      Event.retrieve(options, callback)
  },
  retrieve: function(options, callback){
    $.getJSON("/events/", options, function(events){
      $.each(events, function(_,event){
        callback(event)
      })
    })
  },
  updateParams: function(options){
    var params = {}
    $.each(options, function(key,value){
      params["event["+key+"]"] = value
    })
    params['_method'] = "PUT"
    return params
  },
  update: function(event, options, callback){
    event = Event.instantiate($(event))
    if(typeof(callback) == undefined) callback = function(){}
    $.post(
       event.url,
       Event.updateParams(options),
       function(result){
         event = Event.instantiate(result, 'skipCache')
         callback.apply(event, [event, result])
       },
       "json"
    )
  },
  cachedInstances: [],
  instantiate: function(record, skipCache){

    // if this is a jQuery object just return the actual element
    if(record.jquery)
      return Event.instantiate(record[0], skipCache)

    // return from cache if found
    var id = parseInt(record.id)
    if(!skipCache && id && Event.cachedInstances[id]) {
      return Event.cachedInstances[id]
    } 

    // assume this is an existing DOM object then copy some
    // attributes into the same format as the JSON object has
    $.extend(record,
             { starts_at:  $(record).attr('data-starts-at'),
               ends_at:    $(record).attr('data-ends-at'),
               type:       $(record).attr('data-type'),
               id:         $(record).attr('data-event-id'),
               name:       $(record).attr('data-name')
              })

    // .starts_at and .ends_at are the string attributes
    // but .start and .end are javascript Date objects
    record.start = (new Date(record.starts_at))
    record.end   = Date.parse(record.ends_at) ?
                        (new Date(record.ends_at)) :
                        DateMath.add(record.start, 'minutes', 15)

    $.extend(record, {
      // add methods for event objects here
      // e.g. Event#delete()
      display: Event.displayFor(record),
      url: "/events/"+record.id,
      draw:  Event.draw
    })
    // save instance in the cache
    Event.cachedInstances[record.id] = record
    debug(record.start)
    return record
  },

  draw: function(html){

    var originalDay, newDay, dayContext

    // check whether this event already exists
    var originalEvent = $("li.event[data-event-id="+this.id+"]")
    if(originalEvent.length){
      originalDay = originalEvent.parents("td.day")
      // remove it from its original day
      originalEvent.remove()
    }

    // set a day context
    dayContext = $(html).attr("data-timed") == 'true' ? 'day-full' : 'allday'


    // generalized newday selection, only gets first day
    var newDay = $('.week-' + dayContext + " td.day[data-date="+this.start.strftime("%G-%m-%d")+"]")
    if('AllDay' == this.type){
      var rangeStartDay = this.start
      var rangeEndDay   = this.end
      DateMath.clearTime(rangeStartDay) // noon each day
      DateMath.clearTime(rangeEndDay)
      while(rangeStartDay <= rangeEndDay){
        newDay = newDay.add(
          $(".week-allday td.day[data-date="+rangeStartDay.strftime("%G-%m-%d")+"]")
        )
        rangeStartDay.setDate(rangeStartDay.getDate() + 1)
      }
    }


    // add the event to the new day
    // TODO:
    //   - append the event html into all the days it hits
    //   - refresh all affected days
    newDay.each(function(){
      $(html)
        .prependTo(
          $(this).find(
            dayContext == 'day-full' ?
              "ul" :
              "ul." + $(html).attr("data-type").toLowerCase() + "s"
          )
        )
        .effect("highlight", { color : "#d7fcd7"}, 3000)
    })

    // timed events need to have their day redrawn
    if('allday' != dayContext){
      // redraw the original
      Day.refresh(newDay)
      // and new days
      if(originalDay && originalDay[0] && originalDay[0] != newDay[0])
        Day.refresh(originalDay)
    }

    return this;
  },

  displayFor: function(record){
    switch(record.type){
      case 'Appointment':
      case 'CourtDate': 
        return function(){
           return this.start.getHours()
                + ":"
                + this.start.getMinutes()
                + (this.end ? "&ndash;" + this.end.getHours() + ':' + this.end.getMinutes() : '')
                + " "
                + (this.name ? this.name : 'no name for event #' + this.id)
        }
      default:
        return function(){
           return this.name
        }
    }
  },
  
  // Make sure the start_date is earlier or equal to the end_date
  // Reset values as necessary with optoinal priority
  validateDate: function(record, active) {
    if (active == null) 
      active = 'start'
    if (active == 'start' && record.end < record.start) {
      record.end.setTime(record.start.getTime())
    }
    if (active == 'end' && record.start > record.end) {
      record.start.setTime(record.end.getTime())
    }
    // Make sure to set the starts_at and ends_at values as well
    record.starts_at = record.start.strftime()
    record.ends_at = record.end.strftime()
  },
  
  // Make sure the start is earlier than the end or the end is later than the start
  // Reset values as necessary with optional priority
  validateTime: function(record, active) {
    if (active == null) 
      active = 'start'
    timeOffset = 1000 * 60 * 15; // Default length of event is 15 minutes, the increment we use for most event behavior
    if (active == 'start' && record.end < record.start) {
      record.end.setTime(record.start.getTime() + timeOffset)
    }
    if (active == 'end' && record.start > record.end) {
      record.start.setTime(record.end.getTime() - timeOffset)
    }
    // Make sure to set the starts_at and ends_at values as well
    record.starts_at = record.start.strftime()
    record.ends_at = record.end.strftime()    
  }
}