window.validateEventFormDates = (active) ->
  active = 'start'  unless active
  
  startDate = new Date($('#event_starts_at_datepicker').html() + ' ' + $('#event_starts_at_time').val())
  endDate = new Date($('#event_ends_at_datepicker').html() + ' ' + $('#event_ends_at_time').val())
  debug 'S', startDate
  debug 'E', endDate
  
  if active is 'start' and endDate < startDate
    endDate = new Date(startDate)
    endDate.setHours endDate.getHours() + 2
    $('#event_ends_at_datepicker').html endDate.strftime('%B %e, %Y')
    $('#event_ends_at_time').val endDate.strftime('%i:%M %p')
  if active is 'end' and startDate > endDate
    startDate = new Date(endDate)
    startDate.setHours startDate.getHours() - 2
    $('#event_starts_at_datepicker').html startDate.strftime('%B %e, %Y')
    $('#event_starts_at_time').val startDate.strftime('%i:%M %p')
  
  $('#event_starts_at_date').val startDate.strftime('%B %e, %Y')
  $('#event_ends_at_date').val endDate.strftime('%B %e, %Y')

$ ->
  validateEventFormDates = (active) ->
    active = 'start'  unless active
    
    startDate = new Date($('#event_starts_at_datepicker').html() + ' ' + $('#event_starts_at_time').val())
    endDate = new Date($('#event_ends_at_datepicker').html() + ' ' + $('#event_ends_at_time').val())
    debug 'S', startDate
    debug 'E', endDate
    
    if active is 'start' and endDate < startDate
      endDate = new Date(startDate)
      endDate.setHours endDate.getHours() + 2
      $('#event_ends_at_datepicker').html endDate.strftime('%B %e, %Y')
      $('#event_ends_at_time').val endDate.strftime('%i:%M %p')
    if active is 'end' and startDate > endDate
      startDate = new Date(endDate)
      startDate.setHours startDate.getHours() - 2
      $('#event_starts_at_datepicker').html startDate.strftime('%B %e, %Y')
      $('#event_starts_at_time').val startDate.strftime('%i:%M %p')
    
    $('#event_starts_at_date').val startDate.strftime('%B %e, %Y')
    $('#event_ends_at_date').val endDate.strftime('%B %e, %Y')

  tag_url = '/tags'

  tagResult = (selectedValue) ->
    tags     = $('form#new_event').find('ul.tags')
    existing = tags.find('li').filter(->
      selectedValue is $(this).attr('rel')
    )
    
    $('#tag_entry').val('').focus()

    return  if existing.length
    
    newTag = $('<li></li>').hide()
    newTag.html(selectedValue).attr('rel', selectedValue).append($('<a></a>').html('x').click(->
      newTag.fadeOut 'normal', ->
        $(this).remove()

    )).append($('<input type=hidden></input>').attr('name', 'event[tag_names][]').val(selectedValue)).appendTo(tags).fadeIn 'normal'

  $('#datepicker').datepicker
    changeMonth: true
    changeYear: true
    defaultDate: new Date($('#weeks').data('first-week'))
    onSelect: (dateText, inst) ->
      window.location.href = '/calendar/?date=' + rfc3339(dateText)

  $('form.new_event').submit ->
    form = $(this)
    name = form.find('input#event_name')
    if '' is $.trim(name.val())
      name.focus().effect 'highlight'
      return false
    $.post '/events/', form.serialize(), ((result) ->
      ev = new Event($(result.html)[0], 'skip_cache')
      ev.draw result.html
      form.reset().find('tags li').remove()
    ), 'json'
    false

  $('form.new_event .editable_date').each ->
    editable = $(this)
    editable.editable ((value, settings) ->
      $(this).html value
      validateEventFormDates editable.attr('rel')
    ),
      name: 'event[' + editable.data('field-name') + ']'
      type: 'datepicker'
      tooltip: 'Click to Edit'
      submit: 'OK'
      onblur: 'ignore'

  $('.new_event select.slider_start').val '11:00 AM'
  $('.new_event select.slider_end').val '1:00 PM'
  $('.event_field_times select:first, .event_field_times select:last').selectToUISlider(labels: 5).hide()
  $('#event_ends_at_datepicker').hide()
  $('#event_type').change ->
    switch $(this).val()
      when 'AllDay'
        $('.event_field_times:visible').toggle 'slow'
        $('.event_field_times .ui-slider').remove()
        $('#event_ends_at_datepicker:hidden').toggle 'slow'
        $('.event_field #event_ends_at_date').removeAttr 'disabled'
        $('.event_field #event_remind').val(0).attr 'disabled', 'disabled'
        $('.event_field_remind').addClass 'inactive'
      when 'CourtDate', 'Appointment'
        $('#event_ends_at_datepicker:visible').toggle 'slow'
        $('.event_field_times .ui-slider').remove()
        validateEventFormDates()
        $('.event_field_times select:first, .event_field_times select:last').selectToUISlider labels: 5
        $('.event_field_times:hidden').toggle 'slow'
        $('.event_field #event_ends_at_date').removeAttr 'disabled'
        $('.event_field #event_remind').removeAttr 'disabled'
        $('.event_field_remind').removeClass 'inactive'
      when 'Deadline'
        $('#event_ends_at_datepicker:visible').toggle 'slow'
        $('.event_field_times .ui-slider').remove()
        $('.event_field_times select:first').selectToUISlider labels: 5
        $('.event_field_times:hidden').toggle 'slow'
        $('.event_field #event_ends_at_date').attr 'disabled', 'disabled'
        $('.event_field #event_remind').removeAttr 'disabled'
        $('.event_field_remind').removeClass 'inactive'
      when 'Task'
        $('.event_field_times .ui-slider').remove()
        $('.event_field_times:visible').toggle 'slow'
        $('.event_field_ends_at:visible').toggle 'slow'
        $('.event_field #event_ends_at_date').attr 'disabled', 'disabled'
        $('.event_field #event_remind').removeAttr 'disabled'
        $('.event_field_remind').removeClass 'inactive'

  $('#tag_entry').autocomplete(tag_url,
    matchContains: true
    autoFill: false
    minChars: 0
  ).result((selectedValue) ->
    tagResult selectedValue
  ).change ->
    tagResult $(this).val()

  $('form#new_event').reset ->
    $(this).find('ul.tags').find('li').remove()
    $(this).find('input#event_starts_at_date').val('').end().find('input#event_ends_at_date').val ''
    $(this).find('select#event_starts_at_time').val('11:00 AM').end().find('select#event_ends_at_time').val '1:00 PM'
    $(this).find('select#event_type').change()
