#= require vendor/jquery-1.7.1.min
#= require vendor/jquery-ui-1.9.0.custom.min
#= require vendor/jquery.reveal
#= require vendor/jquery.jeditable
#= require vendor/jquery.jeditable.timepicker
#= require vendor/jquery.jeditable.datepicker
#= require vendor/jquery.timepicker
#= require vendor/jquery.form_prompt
#= require vendor/jquery.pageless
#= require vendor/jquery.selecttouislider
#= require vendor/yui_datemath
#= require vendor/strftime-min

#= require jquery_ujs
#= require select2

#= require_self
#= require_tree

window.debug = ->
  console.debug.apply(console, arguments)

window.rfc3339 = (dateUS) ->
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
