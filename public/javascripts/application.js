
/* allow jQuery to work with Rails' respond_to */
$.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })
