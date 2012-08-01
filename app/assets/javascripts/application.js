
/* use debug(whatever) in any script
 *
 * WARNING: Using this in FF without Firebug enabled breaks the app
 * 
 */
debug = function() {
  console.debug.apply(console, arguments)
}

function rfc3339(dateUS) {
  return dateUS.substr(6,4) + '-' + dateUS.substr(0,2) + '-' + dateUS.substr(3,2);
}

/* allow jQuery to work with Rails' respond_to */
$.ajaxSetup({ 'beforeSend': function(xhr) {
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name=csrf-token]').attr('content'))
}})

/* add the ability to call $('form').reset() */
$.fn.reset = function(fn) {
  fn ? this.bind('reset', fn) : this.trigger('reset')

  return this;
}

$('form').reset(function() {
  $.each(this, function() { this.reset() })
})


// Adding [].indexOf to IE which STILL doesn't support it
if (!Array.indexOf) {
  Array.prototype.indexOf = function(obj) {
    for (var i = 0; i < this.length; i++) {
      if (this[i] == obj) {
        return i;
      }
    }

    return -1;
  }
}

// 'SomeString'.underscore() => 'some_string'
String.prototype.underscore = function() {
  var under = []
    , split = this.split(/([A-Z][a-z]*)/)

  for (var i = 0; i < split.length; i++) {
    if (split[i]) {
      under.push(split[i].toLowerCase())
    }
  }

  return under.join('_');
}

// 'some_string'.camelcase() => 'SomeString'
String.prototype.camelcase = function() {
  var parts     = this.split(/[ _-]+/)
    , len       = parts.length
    , camelized = ''
  
  if (len == 1) { return parts[0]; }

  for (var i = 0; i < len; i++) {
    camelized += parts[i].charAt(0).toUpperCase() + parts[i].substring(1);
  }

  return camelized;
}

/* make any element with a 'placeholder' attribute use the form_prompt plugin for a prompt overlay */
$.fn.form_prompt && $('input[placeholder], textarea[placeholder]').each(function() {
  // check if this has already been called
  if ($(this).parents('.form-prompt-wrapper').length) {
    return;
  }

  $(this).form_prompt($(this).attr('placeholder'))
})
