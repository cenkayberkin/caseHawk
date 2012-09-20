window.setupEventModal = ->
  $('#event-modal .editable_text').each ->
    event = new Event($('#' + $(@).attr('rel')))

    $(@).editable(event.url, {
      name       : 'event[' + $(@).data('field-name') + ']',
      tooltip    : 'Click to Edit',
      submit     : 'OK',
      onblur     : 'ignore',
      width      : 'none',
      height     : 'none',
      submitdata : { '_method': 'PUT' },
      ajaxoptions: { dataType: 'json' },
      callback   : updateSavedEvent
    })

  $('#event-modal .Deadline .event_time.editable').one 'click', ->
    $('#new_event .slider_start').clone().appendTo('#event-modal .event_time')
    $('#event-modal select.slider_start').val($.trim($('.event_time .event_starts_at').data('field-value'))).attr('id', 'event-modal_slider_start')
    $('#event-modal select.slider_start').selectToUISlider({
      labels: 5,
      sliderOptions: {
        change: (e, ui) ->
          startsAtTime = $('#event-modal select.slider_start').val()
          event        = new Event($('#' + $('#event-modal .event-dtails').data('event-id')))

          Event.update(event, { starts_at_time: startsAtTime }, (result) ->
            updateSavedEvent.apply($('#event-modal .event_starts_at'), [result])
          )

          $('#event-modal .event_starts_at').html(startsAtTime)
      }
    }).hide()

  $('#event-modal .Appointment .event_time.editable, #event-modal .CourtDate .event_time.editable').one 'click', ->
    $('#new_event .slider_start, #new_event .slider_end').clone().appendTo('#event-modal .event_time')
    $('#event-modal select.slider_start').val($.trim($('.event_time .event_starts_at').data('field-value'))).attr('id', 'event-modal_slider_start')
    $('#event-modal select.slider_end').val($.trim($('.event_time .event_ends_at').data('field-value'))).attr('id', 'event-modal_slider_end')
    $('#event-modal select.slider_start, #event-modal select.slider_end').selectToUISlider({
      labels: 5,
      sliderOptions: {
        change: (e, ui) ->
          startsAtTime = $('#event-modal select.slider_start').val()
          endsAtTime   = $('#event-modal select.slider_end').val()
          event        = new Event($('#' + $('#event-modal .event-details').data('event-id')))

          Event.update(event, { starts_at_time: startsAtTime, ends_at_time: endsAtTime }, (result) ->
            modal = if ui.value == ui.values[0] then $('#event-modal .event_starts_at') else $('#event-modal .event_ends_at')

            updateSavedEvent.apply(modal, [result])
          )

          $('#event-modal .event_starts_at').html(startsAtTime)
          $('#event-modal .event_ends_at').html(endsAtTime)
      }
    }).hide()

  $('#event-modal .editable_data').each ->
    event = new Event($('#' + $(@).attr('rel')))

    $(@).editable(event.url, {
      name:        'event[' + $(@).data('field-name') + ']',
      type:        'datepicker',
      tooltip:     'Click to Edit',
      submit:      'OK',
      submitdata:  { '_method': 'PUT' },
      ajaxoptions: { dataType: 'json' },
      callback:    updateSavedEvent,
      onblur:      'ignore'
    })

window.updateSavedEvent = (result) ->
  savedEvent    = result.record
  dataFieldName = $(@).data('field-name')

  $('event-modal h3').addClass('event_saving')

  if dataFieldName == 'starts_at_date' || dataFieldName == 'ends_at_date'
    atDate = new Date(savedEvent[dataFieldName])
    $(@).html(atDate.strftime("%B %e, %Y"))
  else
    $(@).html(savedEvent[$(@).data('field-name')])

  new Event($(result.html)[0], 'skip_cache').draw(result.html)

  setTimeout("$('#event-modal h3').removeClass('event_saving')", 1250)
  $(@).effect('highlight', { color: '#d7fcd7' }, 3000)

window.eventTagResult = (selectedValue) ->
  tags     = $('#event-modal').find('ul.tags')
  existing = tags.find('li[data-tag-name=' + selectedValue + ']')
  eventID  = $('#event-modal .event-details').data('event-id')

  $('#new_tag').val('').focus()

  return if existing.length

  $.ajax({
    type:     'POST',
    timeout:  2000,
    dataType: 'json',
    url:      '/taggings',
    data:     { method: 'create', event_id: eventID, tag_name: selectedValue },
    success:  (result) ->
      newTag = $('<li></li>').hide()

      newTag.html(selectedValue).append($('<a></a>').html('x').addClass('tag_remove').attr('rel', result.record.id))
      newTag.attr('id', 'tagging_' + result.record.id)
      newTag.attr('id', 'data-tag-name' + selectedValue)
      newTag.attr('id', 'data-tag-id' + result.record.tag_id)

      newTag.insertBefore('li.new_tag').fadeIn('normal')
  })

$ ->
  $(document).on 'click', '.day_focus_link', ->
    date                  = $(@).data('date')
    focused_cell_selector = 'td[data-date=' + date + '], th[data-date=' + date + ']'
    focus_on_new_day      = !$(@).is('.focused_day')

    $(@).parents('.week').find('.focused_day, .unfocused_day').removeClass('.focused_day, .unfocused_day')

    if focus_on_new_day
      $(@).parents('.week').find('.focused_day, .unfocused_day').removeClass('.focused_day, .unfocused_day')
      $(@).parents('.week').find(focused_cell_selector).addClass('focused_day')
      $(@).parents('.week').find('th:not(.focused_day), td:not(.focused_day)').addClass('unfocused_day')

    return false

  $(document).on 'mouseover', '.collidable li.event', ->
    event    = new Event($(@))
    year     = '' + event.start.getFullYear()
    week     = '' + DateMath.getWeekNumber(event.start)
    week    -= 1
    week     = if week < 10 then '0' + week else week
    hour     = '' + event.start.getHours()
    min      = Math.floor(event.start.getMinutes() / 15) * 15
    min      = if min == 0 then '00' else '' + min
    endStamp = '' + event.end.getHours() + (if event.end.getMinutes() == 0 then '00' else event.end.getMinutes())

    $('#' + year + '-w' + week + '-timerow-' + hour + min).css('background-color', '#e3e6f9')

    while hour + min != endStamp && hour + min != '2400'
      $('#' + year + '-w' + week + '-timerow-' + hour + min).css('background-color', '#e3e6f9')

      if min == '45'
        hour = '' + (parseInt(hour) + 1)
        min  = '00'
      else
        min = '' + (parseInt(min) + 15)

  $(document).on 'click', 'li[data-completable=true] input[type=checkbox]', ->
    li = $(@).parents('li.event')

    Event.update(li, { completed: if li.hasClass('incomplete') then '1' else '' }, (event) ->
      li.removeClass('complete incomplete')
      li.addClass(if event.record.completed_at then 'complete' else 'incomplete')
    )

    li.find('input[type=checkbox]').each ->
      $(@).attr('checked', $(@).attr('checked'))

    return false

  $(document).on 'click', '#event-modal .tag span.name', ->
    Calendar.loadAgenda($(@).text())

    return false

  $(document).on 'click', '#event-modal .event_delete .delete', ->
    $('#event-modal .event_delete_confirm').slideToggle()

  $(document).on 'click', '#event-modal .event_delete .confirm', ->
    eventID = $(@).attr('rel')

    $.ajax({
      url: '/events/' + eventID,
      type: 'DELETE',
      success: (result) ->
        event = $('#' + eventID)
        day   = event.parents('td.day')

        event.remove()

        $('#event-modal').trigger('reveal:close')

        new Day(day).refresh
    })

    return false

  $(document).on 'click', '#event-modal .event_delete .cancel', ->
    $('#event-modal .event_delete_confirm').slideUp()

    return false

  $(document).on 'click', '.event_new_tag', ->
    container = $(@).parent()
    tagForm   = $('<div class="new_tag_input"><label for="new_tag">Tags</label><input tabindex="100" id="new_tag" name="new_tag" type="text" value="" size="30" /><a tabindex="101" class="new_tag_add">Add</a></div>')

    $(@).hide()
    tagForm.hide()
    tagForm.appendTo(container).fadeIn()

    $('#event-modal #new_tag').autocomplete('/tags', {
      matchContains: true,
      autoFill:      false,
      minChars:      0
    }).result (selectedValue) ->
      event_id = $('#event-modal li.event')
      eventTagResult(selectedValue)
    .change ->
      eventTagResult($(@).val())
    .focus()

    return false

  $(document).on 'click', '#event-modal .tag_remove', ->
    $.ajax({
      type:     'POST',
      timeout:  2000,
      dataType: 'json',
      url:      '/taggings/' + $(@).attr('rel'),
      data:     '_method=delete',
      success:  ->
        $('tagging_' + $(@).attr('rel')).fadeOut('normal', ->
          $(@).remove()
        )
    })

    return false

  $(document).on 'click', 'a.event-title', ->
    $.get($(@).attr('href'), (data) ->
      $('#event-modal .content').html(data)
      $('#event-modal').reveal({ animationspeed: 50 })

      setupEventModal()
    )

    return false
  
  setupEventModal()
