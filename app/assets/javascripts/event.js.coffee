class Event
  cachedInstances: []

  constructor: (record, skipeCache) ->
    id        = parseInt(record.id)
    skipCache = skipeCache || false

    return new Event(record[0], skipCache) if record.jquery
    return @cachedInstances[id] if !skipCache && id && @cachedInstances[id]

    $.extend record, {
      starts_at: $(record).data('starts-at')
      ends_at:   $(record).data('ends-at')
      type:      $(record).data('type')
      id:        $(record).data('event-id')
      name:      $(record).data('name')
    }

    $.extend record, {
      url:     '/events/' + record.id
      display: @displayFor(record)
      draw:    @draw
    }

    record.start = new Date(record.starts_at)
    record.end   = if Date.parse(record.ends_at) then new Date(record.ends_at) else DateMath.add(record.start, 'minutes', 15)

    @cachedInstances[record.id] = record

    return record
  
  find: (options, callback) ->
    if options.constructor == Number
      @retrieve { id: options }, callback
    else
      @retrieve options, callback

  retrieve: (options, callback) ->
    $.getJSON '/events', options, (events) ->
      $.each events, (event) ->
        callback(event)

  updateParams: (options) ->
    params = {}

    $.each options, (key, value) ->
      params['event[' + key + ']'] = value

    params['_method'] = 'PUT'

    return params

  update: (event, options, callback) ->
    event    = new Event($(event))
    callback = (->) if typeof(callback) == undefined

    $.post event.url, @updateParams(options), (result) ->
      event = new Event(result, 'skipCache')
      callback.apply(event, [ event, result ])
    , json

  draw: (html) ->
    originalEvent = $('li.event[data-event-id=' + @id + ']')

    if originalEvent.length
      originalDay = originalEvent.parents('td.day')
      originalEvent.remove()

    dayContext = if $(html).data('timed') == true then 'day-full' else 'allday'

    newDay = $('.week-' + dayContext + ' td.day[data-date=' + @start.strftime("%G-%m-%d") + ']')

    if 'AllDay' is @type
      rangeStartDay = @start
      rangeEndDay   = @end

      DateMath.clearTime(rangeStartDay)
      DateMath.clearTime(rangeEndDay)

      while rangeStartDay <= rangeEndDay
        newDay = newDay.add($('.week-allday td.day[data-date=' + rangeStartDay.strftime("%G-%m-%d") + ']'))

        rangeStartDay.setDate(rangeStartDay.getDate() + 1)

    newDay.each ->
      parent = $(@).find((if dayContext is 'day-full' then 'ul' else 'ul.' + $(html).data('type').toLowerCase() + 's'))
      
      $(html).prependTo(parent).effect 'highlight',
        color: '#d7fcd7'
      , 3000

    unless 'allday' is dayContext
      new Day.refresh(newDay)
      new Day.refresh(originalDay) if originalDay and originalDay[0] and originalDay[0] isnt newDay[0]

    return @

  displayFor: (record) ->
    switch record.type
      when 'Appointment', 'CourtDate'
        ->
          @start.getHours() + ':' + @start.getMinutes() + (if @end then '&ndash;' + @end.getHours() + ':' + @end.getMinutes() else '') + ' ' + (if @name then @name else 'no name for event #' + @id)
      else
        ->
          @name

window.Event = Event
