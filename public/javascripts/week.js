Week = {

  loadedWeeks: [],

  // *******
  // The collection of date headers
  // *******
  rollingHeaders: function(){
    return $("table.week-rolling-header")
  },

  // Set the selected rolling header to be 'active', which means locked at the top
  changeWeekHeader: function(header){
    $("table.week-rolling-header")
      .removeClass("rolling-active")
      .addClass("rolling-inactive")
    header
      .addClass("rolling-active")
      .removeClass("rolling-inactive")
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
        Week.loadNext()
      }
    })
  },

  // *******
  // Load the very first week.  Defaults to current
  // *******
  loadFirst : function(){
    if(!$("#weeks").length) return

    if(0 == $("table.week-events").length){
      Week.load(
        new Date($('#weeks').attr('data-first-week')),
        function(){ Week.loadNext(5) } // load the second week right away
      )
      Week.setupEndlessScroll()
    }
  },

  loadNext: function(howMany){
    if(!howMany)
      return

    Week.load(
      DateMath.add(
        (new Date($("#weeks .day:last").attr("data-date").replace(/-/g,'/'))),
        'W',
        1
      ),
      function(){ Week.loadNext(howMany - 1) }
    )
  },

  // *******
  // Retrieve one week's markup remotely
  // *******
  load: function(date, after){
    var formattedDate = date.strftime('%Y-%m-%d')

    if(Week.loadedWeeks.indexOf(formattedDate) > -1)
      return
    Week.loadedWeeks.push(formattedDate)

    $.get(
      "/weeks/"+formattedDate, {},
      function(result) {

        newWeek = $(result)
        $("#weeks").append(newWeek)

        // need to adjust week for event collision, viewport, etc.
        Week.init(newWeek)
        // need to adjust week for event collision, viewport, etc.
        if(after)
          Function == after.constructor && after()
      },
      'html'
    )
  },

  // *******
  // fire all initializing events on the week DOM
  // *******
  init: function(week){
    // prepare header
    Week.initHeader($(week))
    // update facebox links
    week.find('a[rel*=facebox]').facebox()
    // integrate this new week into the rolling headers
    Week.updateRollingHeaders()
    // initialize each day
    week.find("tr.viewport .day").each(function(){
      Day.init($(this))
    })
    // adjust the top and bottom of this week
    Week.adjustViewport($(week))
    // TODO: autofill time inputs and flash for new event form

    // Draw sparklines in the datepicker
    Week.drawInDatepicker($(week))
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
  },
  // Trim the top and bottom off of the calendar
  // to hide the blank space.
  // assumes that Day.boxDayEvents has already executed
  adjustViewport: function(week){
    var boxes = $(week).find(".viewport .collision_box")
    var earliest = boxes.sort(function(a, b){
            return parseFloat($(a).css("top"))
                 > parseFloat($(b).css("top")) ?
                   1 : -1
          })[0]
    var latest = boxes.sort(function(a, b){
            return parseFloat($(a).css("top")) + parseFloat($(a).css("height"))
                 < parseFloat($(b).css("top")) + parseFloat($(b).css("height")) ?
                   1 : -1
          })[0]

    var start_px = Math.min(
                     earliest ?
                       parseFloat($(earliest).css("top")) : 100000000 ,
                     8*60 // 8:00 am
                   ) -30
    var end_px   = Math.max(
                     latest ?
                       parseFloat($(latest).css("top")) + parseFloat($(latest).css("height"))
                       : 0,
                     17*60 // 5:00 pm
                   ) +30

    $(week).find(".day-hours, .day-full").css({
      "margin-top": "-"+start_px+"px",
      "height": end_px+'px'
    })
  },

  drawInDatepicker: function(week){
    var datePicker = $("#datepicker")
    var selectedMonth = parseFloat($("#datepicker .ui-datepicker-month").val())

    $(week).find(".viewport .day").each(function(dayIndex){
      var day = $(this)
      var dayParts = day.attr('data-date').split('-')
      var dayString = parseFloat(dayParts[2])
      var topMargin = parseFloat(day.find('.collidable').css('margin-top'))
 

      // if the datepicker month <select> does not represent the
      // month of the given week then bail
      if( selectedMonth != parseFloat(dayParts[1]) - 1 )
        return


      // measure this box and place a correlating box inside the datepicker
      var cell = datePicker
                    .find("td a")
                    .filter(function(){
                              return dayString.toString() == $(this).text()
                            })
                    .closest('td')

      // add one relatively-positioned div
      holder = $("<div></div>").css({position: 'relative'})
      cell.append(holder)

      // add a baseline
      holder.append(
        $("<div class='sparkler'></div>")
          .css({
            backgroundColor:  '#DDF',
            width:    '100%',
            height:   '2px',
            position: 'absolute',
            bottom:   '0'
          })
      )

      // adding a line across the top for alldays
      holder.append(
        $("<span class='sparkler'></span>")
          .css({
            backgroundColor: '#AFA',
            position: 'absolute',
            padding: '0',
            // 1px correction for top border on datepicker cells
            top: -(cell.closest('td').height() + 1)+'px',
            left: '0',
            // 2px correction for left and right 1px borders on datepicker cells
            width: (cell.width()+2)+'px',
            // calculate the height based on the count of all-day events
            // on this date
            height: Math.min(
                      (week.find(".week-allday .day-"+dayIndex+" .event").length * 2),
                      4
                    )+'px'
          })
      )

      // adding a vertical bar for each collision box
      day.find(".collision_box").each(function(index){
        holder
          .append(
            $("<span class='sparkler'></span>")
              .css({
                backgroundColor:  '#DDF',
                position:         'absolute',
                bottom:           '0',
                height:           '7px',
                padding:          '0',
                width:    (
                            Math.max(
                              (parseFloat($(this).css('height'))/15).toString(),
                              2
                            )
                          )+'px',
                left:     ((parseFloat($(this).css('top')) + topMargin)/15).toString()+"px"
              })
          )
      })
    })
  }
}