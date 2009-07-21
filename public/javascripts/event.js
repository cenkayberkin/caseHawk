// Interface:
// 
// Event.find(4)
//   # returns a single event object
// Event.find({tags: ["one", "two"]})
//   # returns all events matching tags
//   # defaults to timeframe of one month past and one month future
// Event.find({start: '2009-03-04', end: '2009-08-09'})
//   # returns all events in the given timeframe
// Event.find({week: 2})
//   # returns all events of the week 2-weeks before this one
//   # (so, the third week on the list, starting with '0')
// Event.find({tags: ["one", "two"],
//             start: '2009-03-04',
//             end: '2009-08-09'})
//   # returns events matching all given criteria
//   # Event.find calls:
//   Event.retrieve(arguments)
//     # which calls via callback:
//     Event.instantiate(events)
//       # adds helpful event methods to the json object's prototype

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
        callback(Event.instantiate(event))
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

    // if this is a jQuery object just return the
    // actual element
    if(record.jquery) return Event.instantiate(record[0], skipCache)

    // return from cache if found
    var id = parseInt(record.id)
    if(!skipCache && id && Event.cachedInstances[id]){
      debug("returning cache")
      return Event.cachedInstances[id]
    }

    if(2959 == id)
      debug("id for", record)

    // if this is an existing DOM object then copy some
    // attributes into the same format as the JSON object has
    if(record.nodeType){
      $.extend(record,
               { starts_at:  $(record).attr('data-starts-at'),
                 ends_at:    $(record).attr('data-ends-at'),
                 type:       $(record).attr('data-type'),
                 id:         $(record).attr('data-event-id')
                })
      // if(parseInt(record.id) == 2959)
        debug("extending record")
    }
    // otherwise assume the record is a JSON object literal
    // and extend it with a jQuerified DOM object
    else{
      $.extend(record,
               ($("li.event#"+record.id).length ?
                $("li.event#"+record.id) : $("<li></li>"))
                  .attr(
                    { "data-starts-at": record.starts_at,
                      "data-ends-at":   record.ends_at,
                      "type":           record.type,
                      "id":             record.id
                    })
                  .addClass("event")
                  .addClass(record.type)
                  [0])
      // if(parseInt(record.id) == 2959)
        debug("extending jQuery object")
    }
    
    // .starts_at and .ends_at are the string attributes
    // but .start and .end are javascript Date objects
    record.start = (new Date(record.starts_at))
    record.end   = Date.parse(record.ends_at) ?
                        (new Date(record.ends_at)) :
                        record.start.addMinutes(15)

    $.extend(record, {
      // add methods for event objects here
      // e.g. Event#delete()
      display: Event.displayFor(record),
      url: "/events/"+record.id
    })
    // save instance in the cache
    Event.cachedInstances[record.id] = record
    return record
  },
  displayFor: function(record){
    switch(record.type){
      case 'Appointment':
        return function(){
           return this.start.getHours()
                + ":"
                + this.start.getMinutes()
                + (this.end ? "&ndash;"+this.end.toString() : '')
                + " "
                + this.name
        }
      default:
        return function(){
           return this.name
        }
    }
  }
}