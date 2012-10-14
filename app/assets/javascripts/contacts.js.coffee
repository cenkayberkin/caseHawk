# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(document).on 'click', '#sidebar-nav ul li a', ->
    $(@).parents('ul').find('a').removeClass('selected')
    $(@).addClass('selected')

    $('#sidebar .section').hide()
    $('#sidebar').find('.section.' + $(@).data('section')).show()

    return false

  $(document).on 'click', '#sidebar-slideout ul.form-navigation li a', ->
    $(@).parents('ul').find('a').removeClass('selected')
    $(@).addClass('selected')

    $('#sidebar-slideout .section').hide()
    $('#sidebar-slideout').find('.section.' + $(@).data('section')).show()

    return false

  $(document).on 'click', '#sidebar a.add-contact, #sidebar ul.contacts a', ->
    $.get $(@).attr('href'), (result) ->
      $('#sidebar-slideout').html(result).show('slide', { direction: 'right' })

    return false

  $(document).on 'click', '#sidebar-slideout .add_fields', ->
    time   = new Date().getTime()
    regexp = new RegExp($(@).data('id'), 'g')

    $(@).parents('ul').append($(@).data('fields').replace(regexp, time))

    return false

  $(document).on 'click', '#sidebar-slideout form .actions a.cancel', ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })

    return false

  $(document).on 'ajax:success', '#sidebar-slideout form', (xhr, data, status) ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })
    $('#sidebar ul.contacts').replaceWith(data)

  $(document).on 'ajax:error', '#sidebar-slideout form', (xhr, data, status) ->
    $('#sidebar-slideout p.errors').text(JSON.parse(data.responseText).join(', '))

  $(document).on 'ajax:success', '#sidebar-slideout form .actions a.delete', (xhr, data, status) ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })
    $('#sidebar ul.contacts').replaceWith(data)
