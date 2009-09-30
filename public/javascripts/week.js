Week = {

  rollingHeaders: function(){
    return $("table.week-rolling-header")
  },

  // Set the selected rolling header to be 'active', which means locked at the top
  changeWeekHeader: function(week){
    $("table.week-rolling-header").removeClass("rolling-active")
    week.addClass("rolling-active")
  },

  // *******
  // change the header showing dates as the weeks scroll by
  // *******
  updateRollingHeaders: function(){

    // capture header object for fast access
    var headers = Week.rollingHeaders()

    // remove existing event
    $(document).unbind('scroll')
    // add new one
    $(document).scroll(function(){

      var scroll = $(document).scrollTop()

      if(scroll <= headers[0].enter_rolling)
        Week.changeWeekHeader($(headers[0]))
      else
        headers.each(function(idx){
          if(    scroll >= this.enter_rolling
              && scroll <  this.leave_rolling )
                 Week.changeWeekHeader($(this))
        })
    })
  },

  setupEndlessScroll: function(){
    // jQuery plugin for endless page scrolling...
    // Needs configuration and AJAX call, as described:
    // http://www.beyondcoding.com/2009/01/15/release-jquery-plugin-endless-scroll/
    $(document).endlessScroll({
      bottomPixels: 150,
      fireOnce: true,
      fireDelay: 2000,
      callback: function(p) {
        Week.loadAfter(
          new Date($("#weeks .day:last").attr("data-date").replace(/-/g,'/'))
        )
      }
    })
  },

  loadFirst : function(){
    if(0 == $("table.week-events").length){
      Week.load(new Date())
      Week.changeWeekHeader($("table.week-rolling-header:first"))
      Week.setupEndlessScroll()
    }else
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
        Calendar.initWeek($("#weeks div.week:last"))
        // need to bind activateRollingHeader to new week in endlessScroll
        callback && callback()
      },
      'html'
    )
  },

  init: function(week){
    Week.initHeader(week)
    Week.updateRollingHeaders
  },

  initHeader: function(week){
    h = week.find("table.week-rolling-header")
    h.weekOffset = $("#weeks").offset().top
    h.enter_rolling  = $(h).position().top - h.weekOffset
    h.leave_rolling  = h.enter_rolling
                       + $(h).height()
                       + $(h).next("table.week-events").height()
  }
}