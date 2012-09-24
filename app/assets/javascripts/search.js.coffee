$ ->
  $('#search_tag').submit ->
    false

  $('#cal_search #event_tag_search').autocomplete('/tags?by_taggable_type=Event', {
    autoFill: false
    minChars: 0
  }).result (selectedValue) ->
    (new Calendar).loadAgenda(selectedValue)

    $('#mini_cal table').slideUp()
    $('#new_event').children(':gt(0)').slide()

  $('#mini_cal').click ->
    $('#mini_cal table').show()

  $('#new_event input').focus ->
    $('#new_event').children().slideDown()
