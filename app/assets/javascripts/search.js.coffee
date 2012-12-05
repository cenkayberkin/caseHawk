$ ->
  $('#search_tag').submit ->
    false

  $('#cal_search #event_tag_search').autocomplete
    source: '/tags?by_taggable_type=Event'
    minLength: 0
    select: (ev, ui) ->
      (new Calendar).loadAgenda(ui.item.value)

      $('#mini_cal table').slideUp()
      $('#new_event').children(':gt(0)').slideDown()

  $('#mini_cal').click ->
    $('#mini_cal table').show()

  $('#new_event input').focus ->
    $('#new_event').children().slideDown()
