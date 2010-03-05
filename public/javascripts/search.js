$(function(){
  
  $('#cal_search #event_tag_search')
    .autocomplete("/tags?by_taggable_type=Event", {
      matchContains: true,
      autoFill: false,
      minChars: 0
    })
    .result(function(_,_,selectedValue){
      Calendar.loadAgenda(selectedValue)
      $('#mini_cal table').slideUp(); 
      $('#new_event').children(":gt(0)").slideUp(); 
    })

    $('#mini_cal').click(function(){
      $('#mini_cal table').show()
    })
    $('#new_event input').focus(function() {
      $('#new_event').children().slideDown()
    })

})