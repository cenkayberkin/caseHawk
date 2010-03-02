$(function(){
  
  $('#cal_search #event_tag_search')
    .autocomplete("/tags?by_taggable_type=Event", {
      matchContains: true,
      autoFill: false,
      minChars: 0
    })
    .result(function(_,_,selectedValue){
      eventSearchResult(selectedValue)
    })
    .change(function(){ 
      eventSearchResult($(this).val()) 
    })

  function eventSearchResult(tag){
    $.getJSON(
      "/events/",
      {tags: tag},
      function(events){

        var list = $("#cal_search_results")

        if(!events.length){
          list.html("<h3>No results found for <em>"+tag+"</em></h3>")
          return
        }

        list
          .html("<ul class='results'></ul>")
          .show()

        $.each(events, function(_,e){

          var event = Event.instantiate(e)
          list.append(
            $("<li></li>")
              .addClass('event')
              .html(event.display())
          )
          $("table.week li.event#"+event.id)
            .addClass('result')
        }
      )
    })
  }

})