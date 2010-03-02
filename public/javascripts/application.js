
// use log(whatever) in any script
debug = function(){
  console.debug.apply(console, arguments)
}

/* allow jQuery to work with Rails' respond_to */
$.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })

/* add the ability to call $('form').reset() */
$.fn.reset = function(fn){
  fn ? this.bind('reset', fn) : this.trigger('reset')
  return this
}
$("form").reset(function(){
  $.each(this, function(){ this.reset() })
})


// Adding [].indexOf to IE which STILL doesn't support it
if(!Array.indexOf)
  Array.prototype.indexOf = function(obj){
    for(var i=0; i < this.length; i++)
      if(this[i] == obj)
        return i
    return -1
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

/* make any element with a 'placeholder' attribute use the form_prompt plugin for a prompt overlay */
$.fn.form_prompt && $('input[placeholder], textarea[placeholder]').each(function(){
  // check if this has already been called
  if($(this).parents(".form-prompt-wrapper").length)
    return;

  $(this).form_prompt($(this).attr('placeholder'))
})