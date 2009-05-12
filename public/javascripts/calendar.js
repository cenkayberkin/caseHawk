
Calendar = {tags: ''}

$.extend(Calendar, {
  url: function(){
    this.tags == '' ?
      '/calendar/' :
      '/tags/'+this.tags+'/calendar'
  },
  retrieve: function(weeks_ago){
    $.get(this.url(),
          {weeks_ago: weeks_ago || 0},
          function(content){
            console.log(content)
          })
  }
})