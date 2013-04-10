$ ->
  $(document).on 'click', '.edit_account .add_fields', ->
    ul     = $($(@).parents('ul')[0])
    time   = new Date().getTime()
    regexp = new RegExp($(@).data('id'), 'g')

    ul.append($(@).data('fields').replace(regexp, time))

    return false

  $(document).on 'click', '.edit_account a.delete', ->
    li = $($(@).parents('li')[0])

    li.find('[id*=_destroy]').val(true)
    li.hide()

    false
