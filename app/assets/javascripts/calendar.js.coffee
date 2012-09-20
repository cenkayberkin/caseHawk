class Calendar
  loadAgenda: (tag) ->
    spinner = $('#cal_search img.spinner')
    list    = $('#cal_search_results')

    spinner.show()

    $('#cal_search #event_tag_search').attr('value', tag)

    list.html("<h3>Search Results for <span class='search_term'>" + tag + "</span></h3>")
    list.append("<ul class='results'></ul>")

    $.getJSON '/events', { tags: tag, context: 'agenda_' }, (results) ->
      spinner.hide()

      if !results.length
        list.html("<h3 class='no_results'>No results found for <span class='search_term'>" + tag + "</span></h3>")

      @saveRecentTag(tag)

      list.show()

      $('table.week li.event').removeClass('result')

      $.each results, (_, result) ->
        event = Event.instantiate($(result)[0], 'skip_cache')

        $('#cal_search_results ul').append(event)
        $('table.week li.event#' + event.id).addClass('search_result')

      $(document).on 'click', '#cal_search_results h3', ->
        @next('ul').toggle('slow')

  saveRecentTag: (tag) ->
    $.post '/recent_tags/' + tag, { '_method': 'PUT' }

$ ->
  Week.loadFirst()

  $('table.week-events').each(Week.init)
