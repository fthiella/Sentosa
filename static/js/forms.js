$(document).ready(function()
{
  function actions(form, action) {
    
    switch (action) {
      case "save":
      case "insert":
        // if it's insert and is dirty=0 then skip saving
        console.log(action);
        console.log( $('#' + form + ' input#is_dirty').val() );
        if (!((action==="insert") && ($('#' + form + ' input#is_dirty').val()!=="1"))) {
          $.getJSON('db', '_id=' + form + '&button=save&' + $('#' + form).serialize(), function(res) {
            if (res["_status"] === "OK") { // TODO: is this really a good idea?
              $('#' + form + ' input#is_dirty').val('');
              
              if (action==="insert") {
                for (index = 0; index < fields[form].length; ++index) {
                  $('#' + form + ' input#'+fields[form][index]).val('');
                }
              }
            }
          });
        }
        console.log( $('#' + form + ' input#is_dirty').val() );
        // if it's insert and dirty is now=0 then blank the form
        if ((action==="insert") && ($('#' + form + ' input#is_dirty').val()!="1")) {
          for (index = 0; index < fields[form].length; ++index) {
            $('#' + form + ' input#'+fields[form][index]).val('');
          }
        }
        break;
      default:
        $.getJSON('db', '_id=' + form + '&button=' + action + '&' + $('#' + form + ' input#id').serialize()+ '&' + $('#' + form + ' input#goto_record').serialize(), function( res ) {
          $.each( res, function( key, val ) {
          console.log(key, val);
          fields[key] = val;
          $('#' + form + ' input#'+key).val(val);
        })});
        /* LINKED FIELDS
          $("input[name=search_giardini_id]").val(arr[ fields[form][index] ]);
          $("input[name=search_giardini_id]").trigger('keyup');
        */
    }
  }

  function init_form(form) {
      /* buttons management */
      $('#' + form + ' button#save').click(function()      { actions(form, 'save'); });
      $('#' + form + ' button#gotofirst').click(function() { actions(form, 'primo'); });
      $('#' + form + ' button#indietro').click(function()  { actions(form, 'indietro'); });
      $('#' + form + ' button#avanti').click(function()    { actions(form, 'avanti'); });
      $('#' + form + ' button#ultimo').click(function()    { actions(form, 'ultimo'); });
      $('#' + form + ' button#insert').click(function()    { actions(form, 'insert'); });

      /* GOTO_RECORD on Change */
      $('#' + form + ' input#goto_record').change(function() {
        actions(form, 'primo');
      });
  
      /* CHANGE EDIT DATA */
      $('#' + form).change(function() {
        /* intercepts a change on the current form, and sets is_dirty to true */
        $("#is_dirty").val(1);
      }); 

      /* go to the first record, or to the goto_record if specified */
      actions(form, 'primo');
  }

  var fields = new Array();
  // fields['names'] = ["id","name","city"];

  $("form" ).each(function( n ) {
    /* loop and initialize each form in the page */
    
    var form_id = $(this).attr('id');
    
    $.getJSON( "form_data.json?id=" + form_id, function( data ) {
      $.each( data, function( key, val ) {
        console.log(key);
        fields[key] = val;
      });
      
      console.log('form ID = ' + form_id);
      console.log(fields[form_id]);
  
      init_form( form_id );
    });;

  });

});