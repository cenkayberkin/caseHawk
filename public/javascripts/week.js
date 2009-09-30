Week = {

  // *******
  // The collection of date headers
  // *******
  rollingHeaders: function(){
    return $("table.week-rolling-header")
  },

  // Set the selected rolling header to be 'active', which means locked at the top
  changeWeekHeader: function(header){
    $("table.week-rolling-header").removeClass("rolling-active")
    header.addClass("rolling-active")
  },

  // *******
  // change the header showing dates as the weeks scroll by
  // *******
  updateRollingHeaders: function(){

    // capture header object for fast access
    var headers = Week.rollingHeaders()

    if(1 == headers.length)
      Week.changeWeekHeader($("table.week-rolling-header:first"))

    // remove existing event
    // $(document).unbind('scroll')
    // add new one
    $(document).scroll(function(){

      var scroll = $(document).scrollTop()

      if(scroll <= headers[0].enter_rolling){
        Week.changeWeekHeader($(headers[0]))
      }else
        headers.each(function(){
          if(    scroll >= this.enter_rolling
              && scroll <  this.leave_rolling ){
                 Week.changeWeekHeader($(this))
          }
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

  // *******
  // Load the very first week.  Defaults to current
  // *******
  loadFirst : function(){
    if(0 == $("table.week-events").length){
      Week.load(new Date())
      Week.setupEndlessScroll()
    }else
      debug("Already loaded at least one week")
  },

  loadAfter: function(lastWeek){
    Week.load(DateMath.add(lastWeek, 'W', 1))
  },

  // *******
  // Retrieve one week's markup remotely
  // *******
  load: function(date){
    $.get(
      "/weeks/"+date.strftime('%Y-%m-%d'), {},
      function(result) {

        newWeek = $(result)
        $("#weeks").append(newWeek)

        // need to adjust week for event collision, viewport, etc.
        Calendar.initWeek(newWeek)
        Week.init(newWeek)
      },
      'html'
    )
  },

  // *******
  // fire all initializing events on the week DOM
  // *******
  init: function(week){
    // prepare header
    Week.initHeader(week)
    // update facebox links
    week.find('a[rel*=facebox]').facebox()
    // integrate this new week into the rolling headers
    Week.updateRollingHeaders()
  },

  // *******
  // Define when the header should show up as the rolling header
  // *******
  initHeader: function(week){
    h = week.find("table.week-rolling-header")[0]
    h.weekOffset = $("#weeks").offset().top
    h.enter_rolling  = $(h).position().top - h.weekOffset
    h.leave_rolling  = h.enter_rolling
                       + $(h).height()
                       + $(h).next("table.week-events").height()
  }
}