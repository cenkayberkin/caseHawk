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

          debug(result)
          var event = Event.instantiate($(result)[0], 'skip_cache')

          list.append(event)

          $("table.week li.event#"+event.id)
            .addClass('result')
        }
      )
    })
  }

})