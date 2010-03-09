
$(function(){
  // load the first week
  Week.loadFirst()
  // initialize each week on the page
  $("table.week-events").each(Week.init)
})

Calendar = {
  loadAgenda: function(tag){

    var spinner = $("#cal_search img.spinner")
    var list    = $("#cal_search_results")
    
    spinner.show()

    $('#cal_search #event_tag_search').attr('value', tag )
    list.html("<h3>Search Results for <span class=\"search_term\">"+tag+"</span></h3>" + "<ul class='results'></ul>")

    $.getJSON(
      "/events/",
      {tags: tag},
      function(results){

        spinner.hide()

        if(!results.length){
          list.html("<h3 class=\"no_results\">No results found for <span class=\"search_term\">"+tag+"</span></h3>")
          return
        } 

        Calendar.saveRecentTag(tag)

        list.show()

        $("table.week li.event").removeClass('result')

        $.each(results, function(_,result){

          var event = Event.instantiate($(result)[0], 'skip_cache')

          $("#cal_search_results ul").append(event)

          $("table.week li.event#" + event.id)
            .addClass('search_result')
        }
      )
    })
  },

  saveRecentTag: function(tag){
    $.post(
      '/recent_tags/'+tag,
      {
       '_method' : 'PUT'
      },
      function(response){}
    )
  }
}