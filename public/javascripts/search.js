$(function(){
  
  $('#cal_search #search_tag')
    .autocomplete("/tags?by_taggable_type=Event", {
      matchContains: true,
      autoFill: false,
      minChars: 0
    })
    // .result(function(_,_,selectedValue){
    //   var event_id = $('#facebox li.event')
    //   eventTagResult(selectedValue)
    // })
    // .change(function(){ 
    //   eventTagResult($(this).val()) 
    // })

})