class Day
  day: null

  constructor: (day) ->
    return if day.length == 0
    
    @day = day

    if @timed
      @clearBoxes
      @positionEvents(@day.find('.event'))
      @boxDayEvents
      @fixCongestedBoxes

    @clicks

  allday: ->
    @day.is('.week-allday .day')

  timed: ->
    @day.is('.week-day-full .day')

  refresh: ->
    if @timed
      @day.find('.collidable > .event').remove()
      Week.adjustViewport(@day.parents('.week'))

  clearBoxes: ->
    @day.find('.collidable').html(@day.find('.event'))

  positionEvents: (element) ->
    element = if element then element else '.viewport .event'

    $(element).each =>
      event = Event.instantiate(@)

      $(event).css({ top: @top(event) + 'px', height: @height(event) + 'px' })

  clicks: ->
    date      = @.attr('data-date')
    nice_date = new Date(date.replace(/-/g, '/'))

    $(document).on 'click', '[data-date=' + date + ']', ->
      $('#new_event .editable_date').html(nice_date.strftime("%B %e, %Y"))
      $('#event_name').focus()

      validateEventFormDates()

  boxDayEvents: ->
    @clearBoxes

    @day.find('.collidable').each ->
      eventList = $(@)

      events = eventList.find('.event').map( ->
        Event.instantiate(@)
      ).sort((a, b) ->
        if a.starts_at == b.starts_at
          if a.ends_at < b.ends_at then 1 else -1
        else
          if a.starts_at < b.starts_at then 1 else -1
      ).map ->
        @

      latestEventSoFar = events.length && events[0]

      $.each events, (idx, event) ->
        if latestEventSoFar.end >= event.start && latestEventSoFar != event
          @Box(latestEventSoFar, event)
        else
          @Box(event)

        if latestEventSoFar.end < event.end
          latestEventSoFar = event

      @Box.arrange(eventList)

  fixCongestedBoxes: ->
    @day.find('.collision_box').each (box) ->
      lastPosition = parseInt($(box).css('height')) - 15

      $(box).find('.event').each ->
        top = parseInt($(@).css('top'))

        $(@).addClass('too_late') if top > lastPosition
        $(@).addClass('at_the_very_end') if top == lastPosition

      tooLate    = $(box).find('.event.too_late')
      shouldHide = $(box).find('.event.too_late, event.at_the_very_end')

      if tooLate.length
        shouldHide.hide()

        element = $('<li class="event-overflow overflow" style="top: ' + lastPosition + 'px"></li>')
        element.append('<a></a>').html(if shouldHide.length == 1 then (shouldHide.length) + ' events &raquo;' else (shouldHide.length) + ' more &raquo;')

        element.find('a').click ->
          $(@).parents('.collision_box').css({
            height: 'auto'
          }).addClass('collision_box_overflow').find('.event').show().end().end().hide()

          return false

  top: (event) ->
    e = Event.instantiate(event)
    60 * e.start.getHours() + e.start.getMinutes()

  height: (event) ->
    e = Event.instantiate(event)
    @timeDifferentInPixels(if e.end && e.start then e.end - e.start else 0)

  firstStart: (events) ->
    Math.min.apply(null, $.map(events, (event) ->
      e = Event.instantiate(event)
      if e.start then +e.start else 999999999999
    ))

  lastEnd: (events) ->
    Math.max.apply(null, $.map(events, (event) ->
      e = Event.instantiate(event)
      if e.end then +e.end else 0
    ))

  timeDifferentInPixels: (durationInMilliSeconds) ->
    if durationInMilliSeconds > 0 then ((durationInMilliSeconds / 1000) / 60) else 15

  Box: ->
    boxes = []

    boxFn = (a, b) ->
      found = false

      $.each boxes, (box) ->
        $.each box, (cell) ->
          if cell == a
            box.push(b) if b
            found = true
          if cell == b
            box.push(a)
            found = true

      unless found
        if b
          boxes.push([a, b])
        else
          boxes.push([a])

    boxFn.arrange = (eventList) ->
      $.each boxes, (box) ->
        holder    = $('<div class="holder"></div>')
        container = $('<div class="collision_box"></div>')
        boxTop    = $(box[0]).css('top')

        container.css({
          top:    boxTop
          height: @timeDifferentInPixels(@lastEnd(box) - @firstStart(box)) + 'px'
        })

        lastEventTop = boxTop - 15

        $.each box, (element) ->
          top = @top(element) - parseInt(boxTop)
          top = lastEventTop + 15 if top < lastEventTop + 15

          lastEventTop = top

          $(event).css({
            height:   'auto',
            position: 'absolute',
            top:      top + 'px'
          }).appendTo(holder)

        holder.appendTo(container)
        container.appendTo(eventList)

      boxes = []

    return boxFn

window.Day = Day
