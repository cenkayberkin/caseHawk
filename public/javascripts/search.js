$(function(){
  
  $('#cal_search #event_tag_search')
    .autocomplete("/tags?by_taggable_type=Event", {
      matchContains: true,
      autoFill: false,
      minChars: 0
    })
    .result(function(_,_,selectedValue){
      Calendar.loadAgenda(selectedValue)
    })
    .change(function(){ 
      Calendar.loadAgenda($(this).val()) 
    })
})