# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  formValidates = ->
    validates = true
    validates = validateCaseContacts()
    validates = validatesNotes()

    return validates

  validateCaseContacts = ->
    contacts  = $('.section.contacts').find('li.contact')
    validates = true

    $.each contacts, (index, el) ->
      return if validates == false

      validates = false if $(el).find('input.role').val() == ''
      validates = false if $(el).find('input.contact_id').val() == ''

    return validates

  validatesNotes = ->
    notes     = $('.section.notes .notes').find('li.note')
    validates = true

    $.each notes, (index, el) ->
      return if validates == false

      validates = false if $(el).find('input').val() == ''

    return validates

  $(document).on 'submit', '#search_cases, #search_contacts', ->
    false

  $(document).on 'keyup', '#search_cases input', ->
    value = $(@).val();

    $('ul.cases li').each ->
      if $(@).find('a').text().search(value) > -1
        $(@).show()
      else
        $(@).hide()

  $(document).on 'keyup', '#search_contacts input', ->
    value = $(@).val();

    $('ul.contacts li').each ->
      if $(@).find('a').text().search(value) > -1
        $(@).show()
      else
        $(@).hide()

  $(document).on 'click', '#sidebar-nav ul li a', ->
    $(@).parents('ul').find('a').removeClass('selected')
    $(@).addClass('selected')

    $('#sidebar .section').addClass('hidden')
    $('#sidebar').find('.section.' + $(@).data('section')).removeClass('hidden')

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
  $(document).on 'click', '#sidebar a.add, #sidebar ul.contacts li a, #sidebar ul.cases li a', ->
    link = $(@)

    $.get $(@).attr('href'), (result) ->
      $('#sidebar-slideout').html(result).show('slide', { direction: 'right' })

      if link.hasClass('add') && link.hasClass('case')
        $('#sidebar-slideout a[data-section="contacts"]').click()

      $('select#contact_name').select2().on 'change', (e) ->
        $(@).parents('li.contact').find('input.contact_id').val(e.val)

    return false

  # Clicking the X should close the slideout.
  $(document).on 'click', '#sidebar-slideout a.cancel', ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })

    return false

  # Clicking a link to add a new field should append a "starter" set
  # of fields to to the form.
  $(document).on 'click', '#sidebar-slideout .section.contacts .add_fields', ->
    time   = new Date().getTime()
    regexp = new RegExp($(@).data('id'), 'g')

    $(@).parents('ul').append($(@).data('fields').replace(regexp, time))
    $('select#contact_name').select2().on 'change', (e) ->
      $(@).parents('li.contact').find('input.contact_id').val(e.val)

    return false

  $(document).on 'click', '#sidebar-slideout a.delete', ->
    $(@).parents('li').find('[id*=_destroy]').val(true)
    $(@).parents('form').submit() if formValidates()

    $(@).parents('li').remove()

    false

  $(document).on 'click', '#sidebar-slideout .section.notes .list a.note', ->
    id = $(@).data('id')

    $(@).parents('.section').find('li.note').hide()
    $(@).parents('.section').find('li.note[data-id=' + id + ']').show()

  $(document).on 'change', '#sidebar-slideout .section.notes select.templates', ->
    if $(@).val()
      textarea = $(@).parents('.note').find('textarea')
      template = $(@).find(':selected').text()

      textarea.val(template + "\n" + textarea.val())
      textarea.focus()
      textarea.cursorTo(template.length, template.length)

    $(@).val('')

  $(document).on 'blur', '#sidebar-slideout form input, #sidebar-slideout form textarea', ->
    $(@).parents('form').submit() if formValidates()

  $(document).on 'change', '#sidebar-slideout form select', ->
    $(@).parents('form').submit() if formValidates()

  $(document).on 'ajax:success', '#sidebar-slideout form', (xhr, data, status) ->
    $('#sidebar .section:not(.hidden) ul').replaceWith(data.recent)
    $('#sidebar-slideout').html(data.html) if data.html
    $('#sidebar-slideout .summary').html(data.summary) if data.summary

    $('#sidebar-slideout ul.actions li.saved').css('display', 'inline-block').effect "highlight", 3000, ->
      $(this).hide()

    false

  $(document).on 'ajax:error', '#sidebar-slideout form', (xhr, data, status) ->
    $('#sidebar-slideout p.errors').text(JSON.parse(data.responseText).join(', '))

    false

  $(document).on 'ajax:success', '#sidebar-slideout form .actions a.delete', (xhr, data, status) ->
    $('#sidebar-slideout').hide('slide', { direction: 'right' })
    $('#sidebar .section:not(.hidden) ul').replaceWith(data)

    false

  $(document).on 'ajax:success', '#sidebar-slideout a.add_note', (xhr, data, status) ->
    $('#sidebar-slideout .section.notes').html(data)
    $('#sidebar-slideout .section.notes ul li.note:last').show()

    false

  $(document).on 'ajax:success', '#sidebar-slideout a.add_contact', (xhr, data, status) ->
    $('#sidebar-slideout .section.contacts').html(data)
    $('select#contact_name').select2().on 'change', (e) ->
      $(@).parents('li.contact').find('input.contact_id').val(e.val)

    false

  # Assuming the form validates, save it every 2 minutes.
  setInterval ->
    if $('form.edit_case').is(':visible')
      $('form.edit_case').submit() if formValidates()
  , 120000
