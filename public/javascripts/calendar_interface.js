$(function(){

  // Build the enabled datepicker calendar for the sidebar

  $("#datepicker").datepicker({
    changeMonth: true, 
    changeYear: true, 
    onSelect: function(dateText, inst) {
      window.location.href = "/calendars/day?date=" + dateText      
    }
  }); 

  //
  // Add New Event Form
  //
  
  // Change the time and date selects based on event type
  $('#event_type').change(function() {
    switch($(this).val()) {
      case 'AllDay': 
      case 'Appointment': 
        $('.event_field_ends_at:hidden').toggle("slow");          
        $('.event_field:visible #event_ends_at').removeAttr('disabled'); 
        break; 
      case 'Deadline':
      case 'Task': 
        $('.event_field:hidden #event_ends_at').attr('disabled', 'disabled');
        $('.event_field_ends_at:visible').toggle("slow");
        break; 
    }; 
  });
   
  var test_data = "Alpha Beta Gamma Delta Epsilon Zeta Eta Theta Omicron Pi Omega".split(" "); 
  //autocomplete on tag inputs 
  $('#event_tags').autocomplete(test_data, {
    matchContains: true,
    autoFill: false,
    minChars: 0
  }); 

  $('.day').click(function(){
    var day_date = $(this).attr("data-date"); 
    $('#event_starts_at').val(day_date); 
    $('#event_ends_at').val(day_date); 
  })

  // When the user mouses over an event that spans a period of time
  // the timeslot on the left side of the calendar should highlight
  $(".collidable .event").hover(
    function() {
      e = Event.instantiate(this)
      // Treat time parts as string for concatenation with +
      year = "" + e.start.getFullYear()
      week = "" + e.start.getWeek()
      hour = "" + e.start.getHours()
      min = e.start.getMinutes() == 0 ? "00" : "" + e.start.getMinutes()
      //alert("Coloring: " + "#" + year + "-w" + week + "-timerow-" + hour + min)
      endStamp = "" + e.end.getHours() + (e.end.getMinutes() == 0 ? "00" : e.end.getMinutes())
      // Start highlighting the timeline at the appt start time
      $("#" + year + "-w" + week + "-timerow-" + hour + min).css("background-color","#e3e6f9")
      while (hour + min != endStamp && hour + min != "2400") {
        // And keep highlighting until we reachthe end time.
        $("#" + year + "-w" + week + "-timerow-" + hour + min).css("background-color","#e3e6f9")
        if (min == "45") {
          hour = "" + (parseInt(hour) + 1)
          min = "00"
        }
        else {
          min = "" + (parseInt(min) + 15)
        }
      } 
    },
    function(){
      $('.hourslice').css("background-color", "white")
    }
  )

  var functionsThatNeedToBeReexecutedWhenFaceboxLoads = function(){

    // support ajax completion of completable events
    $("li.event_completable input[type=checkbox]")
      .live('click', function(){
        var checkbox = $(this)
        var li = checkbox.parents("li.event_completable")
        Event.update(li,
                     {completed: li.hasClass('incomplete') ? '1' : ''},
                     function(event){
                       li.removeClass('complete incomplete')
                       li.addClass(event.completed_at ? 'complete' : 'incomplete')
                     })
        // if there are multiple checkboxes make sure they all
        // have the same state as this one
        li.find("input[type=checkbox]").each(function(){
          $(this).attr('checked', checkbox.attr('checked'))
        })
      })
  
    $('#facebox .editable')
      .each(function(){
        var editable = $(this)
        var event = Event.instantiate($("#"+editable.attr("rel")))

        editable.editable(
          event.url,
          { name        : "event["+editable.attr("data-field-name")+"]",
            tooltip     : 'Click to Edit',
            submit      : 'OK', 
            onblur      : 'ignore', 
            submitdata  : {"_method": "PUT"},
            ajaxoptions : {dataType: 'json'},
            callback    : function(savedEvent){
              // using the actual saved value
              // in the input field
              $(this).html(
                savedEvent[editable.attr("data-field-name")]
              )
              // update the event on the page too
              // debug(savedEvent)
              // $(event).find(".event-title").html( savedEvent.name )
            }
          }
        )
      })
      
    $('#facebox .editable_time')
      .each(function() {
        var editable = $(this)
        var event = Event.instantiate($("#"+editable.attr("rel")))
      
        editable.editable(
          event.url,
          { name        : "event["+editable.attr("data-field-name")+"]",
            type        : 'timepicker', 
            tooltip     : 'Click to Edit',
            submit      : 'OK', 
            submitdata  : {"_method": "PUT"},
            ajaxoptions : {dataType: 'json'},
            callback    : function(savedEvent){
              // using the actual saved value
              // in the input field
              $(this).html(
                savedEvent[editable.attr("data-field-name")]
              )
              // update the event on the page too
              // debug(savedEvent)
              // $(event).find(".event-title").html( savedEvent.name )      
            }
          }
        )
      })

      $('#facebox .editable_date')
        .each(function() {
          var editable = $(this)
          var event = Event.instantiate($("#" + editable.attr("rel")))

          editable.editable(
            event.url,
            { name        : "event[" + editable.attr("data-field-name") + "]",
              type        : 'datepicker', 
              tooltip     : 'Click to Edit DATE',
              submit      : 'OK', 
              submitdata  : {"_method": "PUT"},
              ajaxoptions : {dataType: 'json'}, 
              callback    : function(savedEvent){
                // using the actual saved value
                // in the input field
                $(this).html(
                  savedEvent[editable.attr("data-field-name")]
                )
                // update the event on the page too
                // debug(savedEvent)
                // $(event).find(".event-title").html( savedEvent.name )      
              }
            }
          )
        })

  }
  
  functionsThatNeedToBeReexecutedWhenFaceboxLoads()
  $(document).bind("reveal.facebox", functionsThatNeedToBeReexecutedWhenFaceboxLoads)

  $('a[rel*=facebox]').facebox()
  
  if ($('#week')) {
    
    // *******
    // change the header showing dates as the weeks scroll by
    // *******
    
    var changeWeekHeader = function(activeWeek){
      // Set the selected rolling header to be 'active', which means locked at the top
      $("table.week-rolling-header").removeClass("rolling-active")
      activeWeek.addClass("rolling-active")
    }
    var activateRollingHeader = function(){
      $("table.week-rolling-header").each(function(){
        this.weekOffset = $("#all_weeks").offset().top
        this.enter_rolling  = $(this).position().top - this.weekOffset
        this.leave_rolling  = this.enter_rolling + $(this).height()
                              + $(this).next("table.week-events").height()
      })
      var rollingHeaders = $("table.week-rolling-header")

      $(document).scroll(function(){
        var scroll = $(document).scrollTop()
        if(scroll <= rollingHeaders[0].enter_rolling)
          changeWeekHeader($(rollingHeaders[0]))
        else
          rollingHeaders.each(function(idx){
            if(    scroll >= this.enter_rolling
                && scroll <  this.leave_rolling )
                   changeWeekHeader($(this))
          })
      })
    }
    // initial header
    changeWeekHeader($("table.week-rolling-header:first"))
    activateRollingHeader()
        
    // jQuery plugin for endless page scrolling...
    // Needs configuration and AJAX call, as described: 
    // http://www.beyondcoding.com/2009/01/15/release-jquery-plugin-endless-scroll/
    $(document).endlessScroll({
      bottomPixels: 150,
      fireOnce: true,
      fireDelay: 2000,
      callback: function(p) {
        day = addWeek($("#week .day:last").attr("data-date"))
        $.ajax({
          url: "/calendars/show/",
          global: true,
          type: "GET",
          dataType: "html",
          data: {
            date: day
          },
          success: function(result) {
            debug(result)
            $("#week .week-events:last").after(result)
            // need to adjust week for event collision, viewport, etc. 
            Calendar.initWeek($("#week .week-events:last"))
            // need to bind activateRollingHeader to new week in endlessScroll
            activateRollingHeader()
          }
        })
        //alert("Found the bottom!")
        //var last_img = $("ul#list li:last");
        //last_img.after(last_img.prev().prev().prev().prev().prev().prev().clone());
      }
    });
  }
})
