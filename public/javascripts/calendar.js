
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

    list.html("<ul class='results'></ul>")

    $.getJSON(
      "/events/",
      {tags: tag},
      function(results){
        spinner.hide()

        if(!results.length){
          list.html("<h3>No results found for <em>"+tag+"</em></h3>")
          return
        }

        Calendar.saveRecentTag(tag)

        list.show()

        $.each(results, function(_,result){

          var event = Event.instantiate($(result)[0], 'skip_cache')

          list.append(event)

          $("table.week li.event#"+event.id).addClass('result')
        }
        Calendar.formatAgenda()
      )
    })
  },

  formatAgenda: function(){
    // TODO: format the agenda view here
  }

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