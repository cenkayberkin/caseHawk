class Week
  week: null
  @loadedWeeks: []

  constructor: (week) ->
    @week = week

    @initHeader()
    @updateRollingHeaders()

    @week.find('tr.viewport .day').each ->
      new Day($(@))

    Week.adjustViewport(@week)
    @drawInDatepicker()

  @load: (date, after) ->
    formattedDate = date.strftime("%Y-%m-%d")

    return if @loadedWeeks.indexOf(formattedDate) > -1

    $.get '/weeks/' + formattedDate,
      (result) ->
        $('#weeks').append(result)
        @constructor($(result))
        Week.loadedWeeks.push(formattedDate)

        after() if after && Function == after.constructor
    , 'html'

  @loadFirst: ->
    return unless $('#weeks').length

    if $('table.week-events').length == 0
      Week.load new Date($('#weeks').data('first-week')), ->
        Week.loadNext(5)

      Week.setupEndlessScroll()

  @loadNext: (howMany) ->
    return unless howMany

    @load DateMath.add((new Date($('#weeks .day:last').data('date').replace(/-/g, '/'))), 'W', 1), ->
      Week.loadNext(howMany - 1)

  @adjustViewport: (week) ->
    boxes = $(week).find('.viewport .collision_box')

    earliest = boxes.sort((a, b) ->
      (if parseFloat($(a).css('top')) > parseFloat($(b).css('top')) then 1 else -1)
    )[0]

    latest = boxes.sort((a, b) ->
      (if parseFloat($(a).css('top')) + parseFloat($(a).css('height')) < parseFloat($(b).css('top')) + parseFloat($(b).css('height')) then 1 else -1)
    )[0]

    start_px = Math.min((if earliest then parseFloat($(earliest).find('li').data('starts-at-time')) * 60 else 100000000), 8 * 60) - 60
    end_px   = Math.max((if latest then parseFloat($(latest).css('top')) + parseFloat($(latest).css('height')) else 0), 17 * 60) + 30

    $(week).find('.day-hours').css {
      'margin-top': '-' + start_px + 'px'
      'height': end_px + 'px'
    }

  @setupEndlessScroll: ->
    $(document).endlessScroll({
      bottomPixels: 150
      fireOnce: true
      fireDelay: 2000
      callback: ->
        Week.loadNext(2)
    })

  rollingHeaders: ->
    return $('table.week-rolling-header')

  initHeader: ->
    header = @week.find('table.week-rolling-header')[0]

    header.weekOffset    = $('#weeks').offset().top
    header.enter_rolling = $(header).position().top - header.weekOffset
    header.leave_rolling = header.enter_rolling + $(header).height() + $(header).next('table.week-events').height()

  updateRollingHeaders: ->
    headers = @rollingHeaders()

    if headers.length == 1
      @changeWeekHeader($('table.week-rolling-header:first'))

    $(document).scroll =>
      scroll = $(document).scrollTop()

      if scroll <= headers[0].enter_rolling
        @changeWeekHeader($(headers[0]))
      else
        headers.each =>
          if scroll >= @enter_rolling && scroll < @leave_rolling
            @changeWeekHeader($(@))

  changeWeekHeader: (header) ->
    $('table.week-rolling-header').removeClass('rolling-active').addClass('rolling-inactive')

    header.addClass('rolling-active').removeClass('rolling-inactive')

  drawInDatepicker: ->
    that = @
    datePicker = $('#datepicker')
    selectedMonth = parseFloat($('#datepicker .ui-datepicker-month').val())

    $(@week).find('.viewport .day').each (index) ->
      dayParts  = $(@).data('date').split('-')
      dayString = parseFloat($(@)[2])
      topMargin = parseFloat($(@).find('.collidable').css('margin-top'))

      return if selectedMonth != parseFloat(dayParts[1]) - 1

      cell = datePicker.find('td a').filter( ->
        return dayString.toString() == $(@).text()
      ).closest('td')

      holder = $('<div></div>').css({ position: 'relative' })

      cell.append(holder)

      holder.append

      holder.append $('<div class="sparkler"></div>').css(
        backgroundColor: '#DDF'
        width: '100%'
        height: '2px'
        position: 'absolute'
        bottom: '0'
      )

      holder.append $('<span class="sparkler"></span>').css(
        backgroundColor: '#AFA'
        position: 'absolute'
        padding: '0'
        top: -(cell.closest('td').height() + 1) + 'px'
        left: '0'
        width: '100%'
        height: Math.min((that.week.find('.week-allday .day-' + index + ' .event').length * 2), 4) + 'px'
      )

      $(@).find('.collision_box').each (index) ->
        holder.append $('<span class="sparkler"></span>').css(
          backgroundColor: '#DDF'
          position: 'absolute'
          bottom: '0'
          height: '7px'
          padding: '0'
          width: (Math.max((parseFloat($(this).css('height')) / 15).toString(), 2)) + 'px'
          left: ((parseFloat($(this).css('top')) + topMargin) / 15).toString()
        )

window.Week = Week
