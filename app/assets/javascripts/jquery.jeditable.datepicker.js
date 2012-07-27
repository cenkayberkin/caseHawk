/*
 * Datepicker for Jeditable (currently buggy, not for production)
 *
 * Copyright (c) 2007-2008 Mika Tuupola
 *
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Depends on Datepicker jQuery plugin by Kelvin Luck:
 *   http://kelvinluck.com/assets/jquery/datePicker/v2/demo/
 *
 * Project home:
 *   http://www.appelsiini.net/projects/jeditable
 *
 * Revision: $Id$
 *
 */
 
$.editable.addInputType('datepicker', {
    /* create input element */
    element : function(settings, original) {
        var input = $('<input>');
        $(this).append(input);
        return(input);
    },
    /* attach 3rd party plugin to input element */
    plugin : function(settings, original) {
        $("input", this)
        .attr("id", "jquery_datepicker_"+(++timepickerFormId))
        .datepicker({createButton:false, dateFormat: 'MM d, yy'})
        .bind('change', function() {
          $(this).submit(); 
        });
    }, 
    submit : function(settings, original) {
      return true; 
    } 
});