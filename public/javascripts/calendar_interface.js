$(function(){

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

  // When the user mouses over an event that spans a period of time
  // the timeslot on the left side of the calendar should highlight
  $(".collidable li.event").live('mouseover',
    function() {
      e = Event.instantiate(this)
      // Treat time parts as string for concatenation with +
      year = "" + e.start.getFullYear()
      week = "" + DateMath.getWeekNumber(e.start)
      week -= 1
      hour = "" + e.start.getHours()
      min = e.start.getMinutes() == 0 ? "00" : "" + e.start.getMinutes()
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
    })
  $(".collidable li.event").live('mouseout', 
    function(){
      $('.hourslice').css("background-color", "white")
    }); 

  // support ajax completion of completable events
  $("li[data-completable=true] input[type=checkbox]")
    .live('click', function(){
      var checkbox = $(this)
      var li = checkbox.parents("li.event")
      Event.update(li,
                   {completed: li.hasClass('incomplete') ? '1' : ''},
                   function(event){
                     li.removeClass('complete incomplete')
                     li.addClass(event.record.completed_at ? 'complete' : 'incomplete')
                   })
      // if there are multiple checkboxes make sure they all
      // have the same state as this one
      li.find("input[type=checkbox]").each(function(){
        $(this).attr('checked', checkbox.attr('checked'))
      })
    })

  // function to call on editable callbacks
  var updateSavedEvent = function(result){
    $("#facebox h3").addClass("event_saving")
    var savedEvent = result.record

    // I'm sorry that I'm special casing this but I need different behavior for dates
    dataFieldName = $(this).attr("data-field-name"); 
    if (dataFieldName == 'starts_at_date' 
        || dataFieldName == 'ends_at_date') {
      atDate = new Date(savedEvent[dataFieldName]); 
      $(this).html(atDate.strftime("%B %e, %Y"))
    } else {
      // using the actual saved value in the input field
      $(this)
        .html(
          savedEvent[$(this).attr("data-field-name")]
        )      
    }

    Event.instantiate($(result.html)[0], 'skip_cache').draw(result.html)

    setTimeout('$("#facebox h3").removeClass("event_saving")', 1250)
    $(this).effect("highlight", { color : "#d7fcd7"}, 3000)
  }

  // ************ Event Details Delete Control ************ //
  // Need to control the event deletion from event details facebox
  $('#facebox .event_delete .delete').live('click', function() { $('#facebox .event_delete_confirm').slideToggle(); }); 
  $('#facebox .event_delete .confirm').live('click', function() {
    var eventID = $(this).attr("rel"); 
    // Call the delete function on this event
    $.post(
      "/events/destroy", 
      { id: eventID }, 
      function(result) {
        // Remove the appropriate event
        var event = $("#" + eventID)
        var day = event.parents("td.day")
        event.remove(); 
        // refresh the day
        Day.refresh(day)
        // Close the facebox
        jQuery(document).trigger('close.facebox'); 
        // redraw page
      }
    ); 
  }); 
  // Close the delete control
  $('#facebox .event_delete .cancel').live('click', function() { $('#facebox .event_delete_confirm').slideUp(); })
  // ************ Event Details Delete FIN ************ //
  // ************ Event Details Tags Control ************ //
  // Need to build the tag interface for existing events
  $('.event_new_tag').live('click', function() {
    var container = $(this).parent(); 
    $(this).hide(); 
    var tagForm = $('<div class="new_tag_input"><label for="new_tag">Tags</label><input tabindex="100" id="new_tag" name="new_tag" type="text" value="" size="30" /><a tabindex="101" class="new_tag_add">Add</a></div>')
      .hide();    

    tagForm
      .appendTo(container)
      .fadeIn(); 
    $('#facebox #new_tag')
      .autocomplete("/tags", {
        matchContains: true,
        autoFill: false,
        minChars: 0    
      })
      .result(function(_,_,selectedValue){ 
        var event_id = $('#facebox li.event')
        eventTagResult(selectedValue); 
      })
      .change(function(){ 
        eventTagResult($(this).val()) 
      })
      .focus(); 
  }); 
  // User has selected a tag
  // Check for existing match then send the tag to the server
  // Show a new tag li on successful save
  function eventTagResult(selectedValue){
    var tags     = $("#facebox").find("ul.tags")
    var existing = tags.find("li[data-tag-name="+selectedValue+"]")
    var eventID  = $("#facebox .event-details").attr("data-event-id"); 
    // clear the search box and start over
    $('#new_tag').val('').focus()
    // do nothing if this tag already exists
    if(existing.length) {
      return; 
    }
    var postUrl = "/taggings"; 
    $.ajax({
      type: "POST", 
      timeout: 2000, 
      dataType: 'json', 
      url: postUrl, 
      data: { method: "create", event_id: eventID, tag_name: selectedValue }, 
      success: function(result) {
        var newTag = $("<li></li>").hide();           
        newTag
          .html(selectedValue)
          .attr('id', "tagging_" + result.record.id)
          .attr('data-tag-name', selectedValue)
          .attr('data-tag-id', result.record.tag_id)
          .append(
            $("<a></a>")
              .html("x")
              .addClass("tag_remove")
              .attr("rel", result.record.id)
          )
          // stick this <li> into the bottom of the <ul>
          .insertBefore("li.new_tag")
          .fadeIn("normal")
      }
    });  
  }
  // Remove an existing tag
  $('#facebox .tag_remove').live('click', function() {
    var self = $(this)
    var postUrl = "/taggings/" + self.attr("rel"); 
    $.ajax({
      type: "POST", 
      timeout: 2000, 
      dataType: 'json', 
      url: postUrl, 
      data: "_method=delete", 
      success: function() {
        $("#tagging_" + self.attr("rel")).fadeOut("normal", function() { $(this).remove() }); 
      }
    });  
  }); 
  // ************ Event Details Tags FIN ************ //

  var functionsThatNeedToBeReexecutedWhenFaceboxLoads = function(){
    // Moved a bunch of functions out of here, replacing them in non-reloaded wrapper
    // Changing click -> live(click,) etc. 
    // Editable event titles
    $('#facebox .editable_text')
      .each(function(){
        var editable = $(this)
        var event = Event.instantiate($("#"+editable.attr("rel")))

        editable.editable(
          event.url,
          { name        : "event["+editable.attr("data-field-name")+"]",
            tooltip     : 'Click to Edit',
            submit      : 'OK', 
            onblur      : 'ignore', 
            width       : 'none',
            height      : 'none', 
            submitdata  : {"_method": "PUT"},
            ajaxoptions : {dataType: 'json'},
            callback    : updateSavedEvent
          }
        )
      })
    
    // Editable Event Time to Slider 
    $('#facebox .Deadline .event_time.editable').one('click', function() {
      $('#new_event .slider_start')
        .clone()
        .appendTo('#facebox .event_time')
      $('#facebox select.slider_start')
        .val($.trim($('.event_time .event_starts_at').attr('data-field-value')))
        .attr("id", "facebox_slider_start")
      $('#facebox select.slider_start')
        .selectToUISlider({
          labels: 5, 
          sliderOptions: {
            change:function(e, ui) {
              startsAtTime = $('#facebox select.slider_start').val()
              var event = Event.instantiate($("#" + $("#facebox .event-details").attr("data-event-id")))
              Event.update(
                event,
                {
                  starts_at_time: startsAtTime, 
                },
                function(result) {
                  updateSavedEvent.apply(
                      $("#facebox .event_starts_at"), 
                    [result]
                  )
                }
              )
              $('#facebox .event_starts_at').html(startsAtTime)
            }
          }
        })
        .hide()      
    })
    
    $('#facebox .Appointment .event_time.editable, #facebox .CourtDate .event_time.editable').one('click', function() {
      $('#new_event .slider_start, #new_event .slider_end')
        .clone()
        .appendTo('#facebox .event_time')
      $('#facebox select.slider_start')
        .val($.trim($('.event_time .event_starts_at').attr('data-field-value')))
        .attr("id", "facebox_slider_start")
      $('#facebox select.slider_end')
        .val($.trim($('.event_time .event_ends_at').attr('data-field-value')))
        .attr("id", "facebox_slider_end")
      $('#facebox select.slider_start, #facebox select.slider_end')
        .selectToUISlider({
          labels: 5, 
          sliderOptions: {
            change:function(e, ui) {
              startsAtTime = $('#facebox select.slider_start').val()
              endsAtTime = $('#facebox select.slider_end').val()
              var event = Event.instantiate($("#" + $("#facebox .event-details").attr("data-event-id")))
              Event.update(
                event,
                {
                  starts_at_time: startsAtTime, 
                  ends_at_time: endsAtTime 
                },
                function(result) {
                  updateSavedEvent.apply(
                    ui.value == ui.values[0] ?
                      $("#facebox .event_starts_at") :
                      $("#facebox .event_ends_at"), 
                    [result]
                  )
                }
              )

              $('#facebox .event_starts_at').html(startsAtTime)
              $('#facebox .event_ends_at').html(endsAtTime)
            }
          }
        })
        .hide()      
    })
    
    // Editable Event Date
    $('#facebox .editable_date')
      .each(function() {
        var editable = $(this)
        var event = Event.instantiate($("#" + editable.attr("rel")))

        editable.editable(
          event.url,
          { name        : "event[" + editable.attr("data-field-name") + "]",
            type        : 'datepicker', 
            tooltip     : 'Click to Edit',
            submit      : 'OK', 
            submitdata  : {"_method": "PUT"},
            ajaxoptions : {dataType: 'json'}, 
            callback    : updateSavedEvent, 
            onblur      : 'ignore'
          }
        )
      })        
      
  }
  
  functionsThatNeedToBeReexecutedWhenFaceboxLoads()
  $(document).bind("reveal.facebox", functionsThatNeedToBeReexecutedWhenFaceboxLoads)
  $(document).bind("reveal.facebox", function(){
    $("form#new_event input").blur()
  })
  

  $('a[rel*=facebox]').facebox()

})
