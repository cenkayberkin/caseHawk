class Day
  day: null
  boxes: []

  constructor: (day) ->
    return if day.length == 0

    @day = $(day)

    if Day.timed(@day)
      @clearBoxes()
      @positionEvents(@day.find('.event'))
      @boxDayEvents()
      @fixCongestedBoxes()

    @clicks()

  @refresh: (day) ->
    if Day.timed(day)
      Week.adjustViewport(day.parents('.week'))

  @timed: (day) ->
    day.parent().is('.week-day-full')

  allday: ->
    @day.parent().is('.week-allday')

  clearBoxes: ->
    @day.find('.collidable').html(@day.find('.event'))
    @boxes = []

  positionEvents: (elements) ->
    elements = if elements then elements else '.viewport .event'

    $(elements).each (index, element) =>
      event = new Event($(element))

      $(event).css({ top: @top(event) + 'px', height: @height(event) + 'px' })

  clicks: ->
    date      = @day.data('date')
    nice_date = new Date(date.replace(/-/g, '/'))

    $(document).on 'click', '[data-date=' + date + ']', ->
      $('#new_event .editable_date').html(nice_date.strftime("%B %e, %Y"))
      $('#event_name').focus()

      validateEventFormDates()

  boxDayEvents: ->
    that = @

    @day.find('.collidable').each ->
      eventList = $(@)

      events = eventList.find('.event').map ->
        new Event($(@))

      events.sort((a, b) ->
        if a.starts_at == b.starts_at
          if a.ends_at < b.ends_at then 1 else -1
        else
          if a.starts_at < b.starts_at then 1 else -1
      ).map ->
        return @

      latestEventSoFar = events.length && events[0]

      $.each events, (index, event) =>
        if latestEventSoFar.end >= event.start && latestEventSoFar != event
          that.newBox(latestEventSoFar, event)
        else
          that.newBox(event)

        if latestEventSoFar.end < event.end
          latestEventSoFar = event

      that.arrange(eventList)

  fixCongestedBoxes: ->
    @day.find('.collision_box').each (index, box) ->
      lastPosition = parseInt($(box).css('height')) - 15

      $(box).find('.event').each (index, event) ->
        top = parseInt($(event).css('top'))

        $(event).addClass('too_late')        if top >  lastPosition
        $(event).addClass('at_the_very_end') if top == lastPosition

      tooLate    = $(box).find('.event.too_late')
      shouldHide = $(box).find('.event.too_late, event.at_the_very_end')

      if tooLate.length > 0
        shouldHide.hide()

        $(box).append $('<li></li>').addClass('event-overflow').addClass('overflow').css('top', lastPosition + 'px').append($('<a></a>').html((if shouldHide.length is 1 then (shouldHide.length) + ' events &raquo;' else (shouldHide.length) + ' more &raquo;')).click( ->
          $(@).parents('.collision_box').css({ height: 'auto' }).addClass('collision_box_overflow').find('.event').show().end().end().hide()

          false
        ))

  top: (event) ->
    return 60 * event.start.getHours() + event.start.getMinutes()

  height: (event) ->
    return @timeDifferentInPixels(if event.end && event.start then event.end - event.start else 0)

  firstStart: (events) ->
    Math.min.apply(null, $.map(events, (event) ->
      e = new Event(event)
      if e.start then +e.start else 999999999999
    ))

  lastEnd: (events) ->
    Math.max.apply(null, $.map(events, (event) ->
      e = new Event(event)
      if e.end then +e.end else 0
    ))

  timeDifferentInPixels: (durationInMilliSeconds) ->
    return if durationInMilliSeconds > 0 then ((durationInMilliSeconds / 1000) / 60) else 15

  newBox: (a, b) ->
    found = false

    $.each @boxes, (box) ->
      $.each box, (cell) ->
        if cell == a
          box.push(b) if b
          found = true
        if cell == b
          box.push(a)
          found = true

    unless found
      if b
        @boxes.push([a, b])
      else
        @boxes.push([a])

  arrange: (eventList) ->
    $.each @boxes, (index, box) =>
      holder    = $('<div class="holder"></div>')
      container = $('<div class="collision_box"></div>')
      boxTop    = $(box).css('top')

      container.css({
        top:    boxTop
        height: @timeDifferentInPixels(@lastEnd(box) - @firstStart(box)) + 'px'
      })

      lastEventTop = boxTop - 15

      $.each box, (index, event) =>
        top = @top(event) - parseInt(boxTop)
        top = lastEventTop + 15 if top < lastEventTop + 15

        lastEventTop = top

        $(event).css({
          height:   'auto'
          position: 'absolute'
          top:      top + 'px'
        })

        $(event).appendTo(holder)

      holder.appendTo(container)
      container.appendTo(eventList)

window.Day = Day
