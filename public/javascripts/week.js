Week = {

  loadFirst : function(){
    if(0 == $("table.week-events").length)
      Week.load(new Date())
    else
      debug("Already loaded at least one week")
  },

  loadAfter: function(lastWeek, callback){
    Week.load(DateMath.add(lastWeek, 'W', 1), callback)
  },

  load: function(date, callback){
    $.get(
      "/weeks/"+date.strftime('%Y-%m-%d'),
      {},
      function(result) {
        // debug(result)
        $("#weeks").append(result)
        // need to adjust week for event collision, viewport, etc.
        Calendar.initWeek($("#weeks table.week:last"))
        // need to bind activateRollingHeader to new week in endlessScroll
        callback && callback()
      },
      'html'
    )
  }
}