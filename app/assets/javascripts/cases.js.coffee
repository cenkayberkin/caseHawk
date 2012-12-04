# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(document).on 'focus', 'input#contact_name', (e) ->
    $(@).autocomplete
      minLength: 1
      source: '/contacts.json'
      select: (event, ui) ->
        $(@).val(ui.item.label)
        $(@).parent().find('input[type=hidden]').val(ui.item.value)

        return false
