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

  $(document).on 'click', '#sidebar a.add-contact', ->
    $.get $(@).attr('href'), (result) ->
      $('#add-contact-modal .content').html(result)
      $('#add-contact-modal').reveal { animationspeed: 50 }

    return false

  $(document).on 'ajax:success', '#add-contact-modal form', ->
    $('#add-contact-modal').trigger('reveal:close')
