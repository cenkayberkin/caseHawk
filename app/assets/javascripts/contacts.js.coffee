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

  # Clicking a tab within the contact form should load the relevant
  # section of said form. This is done through data attributes on both
  # the tab link and the section div.
  $(document).on 'click', '#sidebar-slideout ul.form-navigation li a', ->
    $(@).parents('ul').find('a').removeClass('selected')
    $(@).addClass('selected')

    $('#sidebar-slideout .section').hide()
    $('#sidebar-slideout').find('.section.' + $(@).data('section')).show()

    return false

  # Clicking 'Add Contact' does a GET request using the URL from the link
  # clicked, then puts the result into the slide-out & shows it.
  $(document).on 'click', '#sidebar a.add-contact, #sidebar ul.contacts a', ->
    $.get $(@).attr('href'), (result) ->
      $('#sidebar-slideout').html(result).show('slide', { direction: 'right' })

    return false

  # Clicking the X should close the slideout.
  $(document).on 'click', '#sidebar-slideout a.cancel', ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })

    return false

  # Clicking a link to add a new field should append a "starter" set
  # of fields to to the form.
  $(document).on 'click', '#sidebar-slideout .add_fields', ->
    time   = new Date().getTime()
    regexp = new RegExp($(@).data('id'), 'g')

    $(@).parents('ul').append($(@).data('fields').replace(regexp, time))

    return false

  $(document).on 'blur', '#sidebar-slideout form input, #sidebar-slideout form textarea', ->
    $(@).parents('form').submit()

  $(document).on 'ajax:success', '#sidebar-slideout form', (xhr, data, status) ->
    $('#sidebar ul.contacts').replaceWith(data)
    $('#sidebar-slideout ul.actions li.saved').css('display', 'inline-block').effect "highlight", 3000, ->
      $(this).hide()

  $(document).on 'ajax:error', '#sidebar-slideout form', (xhr, data, status) ->
    $('#sidebar-slideout p.errors').text(JSON.parse(data.responseText).join(', '))

  $(document).on 'ajax:success', '#sidebar-slideout form .actions a.delete', (xhr, data, status) ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })
    $('#sidebar ul.contacts').replaceWith(data)
