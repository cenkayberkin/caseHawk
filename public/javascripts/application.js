
// use log(whatever) in any script
log = function(){
  console.log.apply(console,arguments)
}

/* allow jQuery to work with Rails' respond_to */
$.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })

// "SomeString".underscore() => "some_string"
String.prototype.underscore = function(){
  var under = [];
  for each(var word in this.split(/([A-Z][a-z]*)/))
    if(word)
      under.push(word.toLowerCase())
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
