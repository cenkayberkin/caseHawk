Week = {

  loadFirst : function(){
    if(0 == $("table.week-events").length)
      debug("Already loaded at least one week")
    else
      Week.load(new Date())
  },

  loadAfter: function(lastWeek, callback){
    load(DateMath.add(lastWeek, 'week', 1), callback)
  },

  load: function(date, callback){
    $.ajax({
      url: "/calendars/show/",
      global: true,
      type: "GET",
      dataType: "html",
      data: { date: date },
      success: function(result) {
        // debug(result)
        $("#week .week-events:last").after(result)
        // need to adjust week for event collision, viewport, etc.
        Calendar.initWeek($("#week .week-events:last"))
        // need to bind activateRollingHeader to new week in endlessScroll
        callback && callback()
      }
    })
  }
}