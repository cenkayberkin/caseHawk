
$(function(){
  // Build the enabled datepicker calendar for the sidebar
  $("#datepicker").datepicker({
    changeMonth: true,
    changeYear: true,
    defaultDate: new Date($('#weeks').attr('data-first-week')),
    onSelect: function(dateText, inst) {
      window.location.href = "/calendar/?date=" + rfc3339(dateText)
    }
  }); 

  //
  // Add New Event Form

  $("form.new_event").submit(function(){

    var form = $(this)
    var name = form.find("input#event_name")

    if('' == $.trim(name.val())){
      name.focus().effect("highlight")
      return false
    }

    $.post(
       '/events/',
       form.serialize(),
       function(result){
         Event.instantiate(
                $(result.html)[0], 'skip_cache'
              )
              .draw(result.html)
         form
          .reset()
          .find("tags li")
            .remove()
         // TODO: do whatever's needed to finish resetting the form
       },
       "json"
    )
    return false
  })
  //  
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
  // Create the time sliders for new event form 
  $('.new_event select.slider_start').val("11:00 AM")
  $('.new_event select.slider_end').val("1:00 PM")
  $('.event_field_times select:first, .event_field_times select:last').selectToUISlider({labels: 5}).hide()
  // Hide the event_ends_at_datepicker by default
  $('#event_ends_at_datepicker').hide()

  // Change the time and date selects based on event type
  $('#event_type').change(function() {
    switch($(this).val()) {
      case 'AllDay': 
        $('.event_field_times:visible').toggle("slow")
        $('.event_field_times .ui-slider').remove(); 
        $('#event_ends_at_datepicker:hidden').toggle("slow")

        $('.event_field #event_ends_at_date').removeAttr('disabled')

        $('.event_field #event_remind').val(0).attr("disabled", "disabled")
        $('.event_field_remind').addClass("inactive")
        break 
      case 'CourtDate': 
      case 'Appointment': 
        $('#event_ends_at_datepicker:visible').toggle("slow") 
        $('.event_field_times .ui-slider').remove(); 
        validateEventFormDates()
        $('.event_field_times select:first, .event_field_times select:last').selectToUISlider({labels: 5})
        $('.event_field_times:hidden').toggle("slow")        

        $('.event_field #event_ends_at_date').removeAttr('disabled')

        $('.event_field #event_remind').removeAttr("disabled")
        $('.event_field_remind').removeClass("inactive")
        break 
      case 'Deadline':
        $('#event_ends_at_datepicker:visible').toggle("slow")
        $('.event_field_times .ui-slider').remove(); 
        $('.event_field_times select:first').selectToUISlider({labels: 5})
        $('.event_field_times:hidden').toggle("slow")

        $('.event_field #event_ends_at_date').attr('disabled', 'disabled')

        $('.event_field #event_remind').removeAttr("disabled")
        $('.event_field_remind').removeClass("inactive")
        break 
      case 'Task': 
        $('.event_field_times .ui-slider').remove(); 
        $('.event_field_times:visible').toggle("slow") 
        $('.event_field_ends_at:visible').toggle("slow")

        $('.event_field #event_ends_at_date').attr('disabled', 'disabled')

        $('.event_field #event_remind').removeAttr("disabled")
        $('.event_field_remind').removeClass("inactive")
        break 
    };     
  });
   
  //autocomplete on tag inputs 
  var tag_url = "/tags"; 
  $('#tag_entry')
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
    var existing = tags.find("li").filter(function(){
                                      return selectedValue == $(this).attr('rel')
                                    })

    // clear the search box and start over
    $('#tag_entry').val('').focus()

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

  // The following should happen to reset the form to pristine state
  $("form#new_event").reset(function(){
    // remove any tags that have accumulated
    $(this)
      .find("ul.tags")
        .find("li")
          .remove()

    // reset the dates
    $(this)
      .find("input#event_starts_at_date")
        .val("")
        .end()
      .find("input#event_ends_at_date")
        .val("")

    /* leave the datetime resets as they are */

    // reset the selects behind the slider
    $(this)
      .find("select#event_starts_at_time")
        .val("11:00 AM")
        .end()
      .find("select#event_ends_at_time")
        .val("1:00 PM")

    // fire the slider reset
    $(this)
      .find("select#event_type")
        .change()
  })

})
function validateEventFormDates(active) {

  if (!active) active = 'start'

  // new to construct full dates for start and end
  // editable only sets the inner HTML on submission then calls this validation
  startDate = new Date($('#event_starts_at_datepicker').html() + " " + $('#event_starts_at_time').val()); 
  endDate = new Date($('#event_ends_at_datepicker').html() + " " + $('#event_ends_at_time').val()); 
  debug("S", startDate)
  debug("E", endDate)
  // check for valid endDate
  if (active == 'start' && endDate < startDate) {
    endDate = new Date(startDate); 
    endDate.setHours(endDate.getHours() + 2);
    $('#event_ends_at_datepicker').html(endDate.strftime("%B %e, %Y")); 
    $('#event_ends_at_time').val(endDate.strftime("%i:%M %p")); 
  } 
  if (active == 'end' && startDate > endDate) {
    startDate = new Date(endDate); 
    startDate.setHours(startDate.getHours() - 2);
    $('#event_starts_at_datepicker').html(startDate.strftime("%B %e, %Y")); 
    $('#event_starts_at_time').val(startDate.strftime("%i:%M %p")); 
  }
  // set all applicable hiddens
  $('#event_starts_at_date').val(startDate.strftime("%B %e, %Y"));
  $('#event_ends_at_date').val(endDate.strftime("%B %e, %Y")); 
}
