$(function(){

  // Build the enabled datepicker calendar for the sidebar

  $("#datepicker").datepicker({
    changeMonth: true, 
    changeYear: true, 
    defaultDate: new Date($('#weeks').attr('data-first-week')),
    onSelect: function(dateText, inst) {
      window.location.href = "/calendar/?date=" + dateText      
    }
  }); 

  //
  // Add New Event Form
  //  
  // Create timepicker clickables for new event form
  $('form.new_event .editable_time')
    .each(function() {
      var editable = $(this)
      editable.editable(
        function(value, settings) {
          $(this).html(value); 
          validateEventFormDates(editable.attr("rel"));           
        },
        { 
          name        : "event["+editable.attr("data-field-name")+"]",
          type        : 'timepicker', 
          tooltip     : 'Click to Edit',
          submit      : 'OK'
        }
      )
    }); 
  // Create datepicker clickables for new event form
  $('form.new_event .editable_date')
    .each(function() {
      var editable = $(this)
      editable.editable(
        function(value, settings) {
          $(this).html(value); 
          validateEventFormDates(editable.attr("rel"));           
        },
        { 
          name        : "event["+editable.attr("data-field-name")+"]",
          type        : 'datepicker', 
          tooltip     : 'Click to Edit',
          submit      : 'OK',
          onblur      : 'ignore'
        }
      )
    });

  // expand a single day within the week view
  $(".day_focus_link").live('click', function(){
    var date = $(this).attr('data-date')
    var focused_cell_selector = "td[data-date="+date+"],th[data-date="+date+"]"
    var focus_on_new_day = (!$(this).is(".focused_day"))

    // back out of any currently focused day
    $(this)
      .parents(".week")
        .find(".focused_day, .unfocused_day")
          // .animate({width: 'auto'}, 500)
          .removeClass('focused_day unfocused_day')
          .end()

    // focus on a new day if the user clicked something other
    // than the currently focused day
    if(focus_on_new_day)
      $(this)
        .parents(".week")
          .find(".focused_day, .unfocused_day")
            // .animate({width: 'auto'}, 500)
            .removeClass('focused_day unfocused_day')
            .end()
          .find(focused_cell_selector)
            // .animate({width: '50%'}, 500)
            .addClass('focused_day')
            .end()
          .find("th:not(.focused_day),td:not(.focused_day)")
            .addClass("unfocused_day")
            .end()
  })

  // Change the time and date selects based on event type
  $('#event_type').change(function() {
    switch($(this).val()) {
      case 'AllDay': 
        $('.editable_time').hide(); 
        $('.event_field_ends_at:hidden').toggle("slow");          
        $('.event_field:visible #event_ends_at').removeAttr('disabled'); 
        break; 
      case 'Appointment': 
        $('.editable_time').show(); 
        $('.event_field_ends_at:hidden').toggle("slow");          
        $('.event_field:visible #event_ends_at').removeAttr('disabled'); 
        break; 
      case 'Deadline':
        $('.editable_time').show(); 
        $('.event_field:hidden #event_ends_at').attr('disabled', 'disabled');
        $('.event_field_ends_at:visible').toggle("slow");
        break; 
      case 'Task': 
        $('.editable_time').hide(); 
        $('.event_field:hidden #event_ends_at').attr('disabled', 'disabled');
        $('.event_field_ends_at:visible').toggle("slow");
        break; 
    };     
  });
   
  //autocomplete on tag inputs 
  var tag_url = "/tags"; 
  $('#event_tags')
    .autocomplete(tag_url, {
      matchContains: true,
      autoFill: false,
      minChars: 0    
    })
    .result(function(_,_,selectedValue){ 
      tagResult(selectedValue); 
    })
    .change(function(){ 
      tagResult($(this).val()) 
    })

  function tagResult(selectedValue){

    var tags     = $("form#new_event").find("ul.tags")
    var existing = tags.find("li[rel="+selectedValue+"]")

    // clear the search box and start over
    $('#event_tags').val('').focus()

    // do nothing if this tag already exists
    if(existing.length)
      return;

    var newTag = $("<li></li>").hide()
    newTag
      .html(selectedValue)
      .attr('rel', selectedValue)
      // a delete link
      .append(
        $("<a></a>")
          .html("x")
          .click(function(){ newTag.fadeOut("normal", function() { $(this).remove() }) })
      )
      // the input that will save this value
      .append(
        $("<input type=hidden></input>")
          .attr('name', 'event[tag_names][]')
          .val(selectedValue)
      )
      // stick this <li> into the bottom of the <ul>
      .appendTo(tags)
      .fadeIn("normal")
  }

  // When the user mouses over an event that spans a period of time
  // the timeslot on the left side of the calendar should highlight
  $(".collidable .event").hover(
    function() {
      e = Event.instantiate(this)
      // Treat time parts as string for concatenation with +
      year = "" + e.start.getFullYear()
      week = "" + DateMath.getWeekNumber(e.start)
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
            callback    : function(result){
              var savedEvent = result.record

              // using the actual saved value
              // in the input field
              $(this).html(
                savedEvent[editable.attr("data-field-name")]
              )
              Event.instantiate(savedEvent).draw(result.html)
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
              updateEvent = Event.instantiate(savedEvent).draw();       
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
                updateEvent = Event.instantiate(savedEvent).draw(); 
              }
            }
          )
        })
        
        $('#facebox .new_tag_input').hide(); 
        $('.event_new_tag').click(function() {
//          $(this).hide(); 
//          $('#facebox .new_tag_input').fadeIn(); 
//          $('#facebox .new_tag_input input').focus(); 
        }); 
  }
  
  functionsThatNeedToBeReexecutedWhenFaceboxLoads()
  $(document).bind("reveal.facebox", functionsThatNeedToBeReexecutedWhenFaceboxLoads)

  $('a[rel*=facebox]').facebox()

})
function validateEventFormDates(active) {

  if (!active) active = 'start'

  // new to construct full dates for start and end
  // editable only sets the inner HTML on submission then calls this validation
  startDate = new Date($('#event_starts_at_datepicker').html() + " " + $('#event_starts_at_timepicker').html()); 
  endDate = new Date($('#event_ends_at_datepicker').html() + " " + $('#event_ends_at_timepicker').html());
  // check for valid endDate
  if (active == 'start' && endDate < startDate) {
    endDate = startDate; 
    $('#event_ends_at_datepicker').html(endDate.strftime("%B %e, %Y")); 
    $('#event_ends_at_timepicker').html(endDate.strftime("%I:%M %p")); 
  } 
  if (active == 'end' && startDate > endDate) {
    startDate = endDate; 
    $('#event_starts_at_datepicker').html(startDate.strftime("%B %e, %Y")); 
    $('#event_starts_at_timepicker').html(startDate.strftime("%I:%M %p")); 
  }
  // set all applicable hiddens
  $('#event_starts_at').val(startDate.strftime("%B %e, %Y %I:%M %p"));
  $('#event_ends_at').val(endDate.strftime("%B %e, %Y %I:%M %p")); 
}
