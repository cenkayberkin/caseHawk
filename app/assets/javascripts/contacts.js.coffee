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

  $(document).on 'click', '#sidebar a.add-contact, #sidebar ul.contacts a', ->
    $.get $(@).attr('href'), (result) ->
      $('#sidebar-slideout').html(result).show('slide', { direction: 'right' })

    return false

  $(document).on 'click', '#sidebar-slideout form .actions a', ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })

  $(document).on 'ajax:success', '#sidebar-slideout form', ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })
