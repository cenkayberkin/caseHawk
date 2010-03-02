
$(function(){
  // load the first week
  Week.loadFirst()
  // initialize each week on the page
  $("table.week-events").each(Week.init)
})

Calendar = {
  loadAgenda: function(tag){
    $.getJSON(
      "/events/",
      {tags: tag},
      function(results){

        var list = $("#cal_search_results")

        if(!results.length){
          list.html("<h3>No results found for <em>"+tag+"</em></h3>")
          return
        }

        list
          .html("<ul class='results'></ul>")
          .show()

        $.each(results, function(_,result){

          var event = Event.instantiate($(result)[0], 'skip_cache')

          list.append(event)

          $("table.week li.event#"+event.id)
            .addClass('result')
        }
      )
    })
  }
}