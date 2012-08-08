debug = ->
  console.debug.apply(console, arguments_)

rfc3339 = (dateUS) ->
  dateUS.substr(6, 4) + '-' + dateUS.substr(0, 2) + '-' + dateUS.substr(3, 2)

unless Array.indexOf
  Array::indexOf = (obj) ->
    i = 0

    while i < @length
      return i  if this[i] is obj

      i++
    -1

String::underscore = ->
  under = []
  split = @split(/([A-Z][a-z]*)/)
  
  i = 0
  while i < split.length
    under.push split[i].toLowerCase()  if split[i]
 
    i++
  
  under.join '_'


String::camelcase = ->
  parts = @split(/[ _-]+/)
  len = parts.length
  camelized = ''
  
  return parts[0]  if len is 1
  
  i = 0
  while i < len
    camelized += parts[i].charAt(0).toUpperCase() + parts[i].substring(1)
    
    i++
  
  camelized

$.fn.reset = (fn) ->
  if fn then @bind('reset', fn) else @trigger('reset')

  this

$ ->

  $.ajaxSetup beforeSend: (xhr) ->
    xhr.setRequestHeader 'X-CSRF-Token', $('meta[name=csrf-token]').attr('content')

  $.fn.form_prompt and $('input[placeholder], textarea[placeholder]').each(->
    return  if $(this).parents('.form-prompt-wrapper').length
    
    $(this).form_prompt $(this).attr('placeholder')
  )

  $('form').reset ->
    $.each this, @reset()
