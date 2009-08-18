
// use log(whatever) in any script
debug = function(){
  var args = arguments
  // adding delay to let Firebug time to load
  setTimeout(function(){
    console.debug.apply(console, args)
  }, 50)
}

/* allow jQuery to work with Rails' respond_to */
$.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })

// Extend the Date object to tell us the week of the year
// This counts week 1 as the first week containing a Sunday (which 
// matches the ruby strftime('%U') method)
Date.prototype.getWeek = function() {
  var oneJan = new Date(this.getFullYear(),0,1)
  oneJan.setDate(oneJan.getDate() + ((7-oneJan.getDay())%7))
  return Math.ceil(((this - oneJan) / 86400000)/7)
}

// add a given number of minutes to a date
// returns a new Date() object
// does not change the original object
Date.prototype.addMinutes = function(minutes) {
  var copy = new Date()
  copy.setTime(this.valueOf())
  var newMinutes = this.getMinutes() + minutes
  var newHours   = this.getHours()

  if(newMinutes > 59){
    newMinutes = newMinutes % 60
    newHours   = newHours + 1
    // TODO: build more comprehensive function
    //       for fixing date modulus rollovers like this
  }

  copy.setMinutes(newMinutes)
  copy.setHours(newHours)
  return copy
}

// "SomeString".underscore() => "some_string"
String.prototype.underscore = function(){
  var under = [];
  var split = this.split(/([A-Z][a-z]*)/)
  for(var i=0; i < split.length; i++)
    if(split[i])
      under.push(split[i].toLowerCase())
  return under.join("_")
}

// "some_string".camelcase() => "SomeString"
String.prototype.camelcase = function(){
  var parts = this.split(/[ _-]+/), len = parts.length;
  if (len == 1) return parts[0];

  var camelized = ""
  for (var i = 0; i < len; i++)
    camelized += parts[i].charAt(0).toUpperCase() + parts[i].substring(1);

  return camelized;
}


// Set up hidable sidebar elements
$(function(){
  $(".expandable").hide()
  $(".expandable, .collapsible").prev().addClass("clickable")
  $(".expandable, .collapsible").prev().click(function() {
    $(this).toggleClass("clicked")
    $(this).next().slideToggle()
  })
})

