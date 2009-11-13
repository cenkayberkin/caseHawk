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

  // Hide the event_ends_at_datepicker by default
  $('#event_ends_at_datepicker').hide(); 

  // Change the time and date selects based on event type
  $('#event_type').change(function() {
    switch($(this).val()) {
      case 'AllDay': 
        $('.editable_time').hide(); 
        $('#event_ends_at_datepicker').show(); 
        $('.event_field_ends_at:hidden').toggle("slow");          
        $('.event_field:visible #event_ends_at').removeAttr('disabled'); 
        $('.event_field #event_remind').val(0); 
        $('.event_field_remind').toggle("slow"); 
        break; 
      case 'CourtDate': 
      case 'Appointment': 
        $('#event_ends_at_datepicker').hide(); 
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
  $("li.event_completable input[type=checkbox]")
    .live('click', function(){
      var checkbox = $(this)
      var li = checkbox.parents("li.event_completable")
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

    setTimeout('$("#facebox h3").removeClass("event_saving")', 2000)
    $("#"+savedEvent.id+".event").effect("highlight", { color : "#d7fcd7"}, 3000)
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
        $("#" + eventID).remove(); 
        // Close the facebox
        jQuery(document).trigger('close.facebox'); 
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
            submitdata  : {"_method": "PUT"},
            ajaxoptions : {dataType: 'json'},
            callback    : updateSavedEvent
          }
        )
      })
    
    // Editable Event Time
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
            callback    : updateSavedEvent
          }
        )
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
            tooltip     : 'Click to Edit DATE',
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
  $(document).bind("reveal.facebox", function() { functionsThatNeedToBeReexecutedWhenFaceboxLoads(); $('input').blur(); })

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
    endDate = new Date(startDate); 
    endDate.setHours(endDate.getHours() + 1); 
    $('#event_ends_at_datepicker').html(endDate.strftime("%B %e, %Y")); 
    $('#event_ends_at_timepicker').html(endDate.strftime("%i:%M %p")); 
  } 
  if (active == 'end' && startDate > endDate) {
    startDate = new Date(endDate); 
    startDate.setHours(startDate.getHours() - 1); 
    $('#event_starts_at_datepicker').html(startDate.strftime("%B %e, %Y")); 
    $('#event_starts_at_timepicker').html(startDate.strftime("%i:%M %p")); 
  }
  // set all applicable hiddens
  $('#event_starts_at').val(startDate.strftime("%B %e, %Y %i:%M %p"));
  $('#event_ends_at').val(endDate.strftime("%B %e, %Y %i:%M %p")); 
}
