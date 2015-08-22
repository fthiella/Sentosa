var asInitVals = new Array(); /* for datatables */

$(document).ready(function()
{
  /* ************** */
  /* form functions */
  /* ************** */
  function actions(form, action) {    
    /* TODO: if is_dirty=1 then try to save the current record first, if save succedes then proceed with the action */
    /* recursion? but we need to be careful as code has to be asyncronous! */

    switch (action) {
      case "save":
      case "insert":
        // if it's insert and is dirty=0 then skip saving
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
        // if it's insert and dirty is now=0 then blank the form
        if ((action==="insert") && ($('#' + form + ' input#is_dirty').val()!="1")) {
          for (index = 0; index < fields[form].length; ++index) {
            $('#' + form + ' input#'+fields[form][index]).val('');
          }
        }
        break;
      default:
        /* TODO: check is_dirty first! and is_dirty will have a unique name */
        $.getJSON(
          'db',
          '_id=' + form + '&' +
          'button=' + action + '&' +
          $('#' + form + ' input#id').serialize()+ '&' +
          $('input#' + form + '_goto_record').serialize(),
          function( res ) {
            $.each( res, function( key, val ) {
              fields[key] = val;
              $('#' + form + ' input#'+key).val(val);
              
              /* force a change whenever a field linked to a table is changed */
              /* TODO: linked fields, make it simpler/clearer/better/more performant? */
              if ($('#' + form + ' input#' + key).data('to-table')) {
                $('#' + form + ' input#' + key).change();
              }
            })
          }
        )
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
      
      /* TODO: improve link between form and subquery */
      $("#" + form).find('input').each(function( n ) {
        if ($(this).data('to-table')) {
          var to_field = "input[name="+ $(this).data('to-table') + "_search_" + $(this).data('to-field') +"]";
          var from_field = '#' + $(this).data('from-form') + ' input#' + $(this).data('from-field');
          
          $(from_field).change(function() {
            $(to_field).val( $(from_field).val() );
            $(to_field).trigger('keyup');
          })
        }
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

  /* ******************** */
  /* Datatables functions */
  /* ******************** */
  function init_table(table, ajax_source) {
    var oTable = $('#' + table).dataTable( {
      "bProcessing": true,
      "bServerSide": true,
      "sAjaxSource": ajax_source,
  
      "oLanguage": {
        "sLengthMenu":   "Mostra _MENU_ righe per pagina",
        "sZeroRecords":  "Nessun risultato",
        "sInfo":         "Da _START_ a _END_ di _TOTAL_ righe",
        "sInfoEmpty":    "Nessun risultato",
        "sInfoFiltered": "(_MAX_ totali)",
        "sSearch":       "Cerca:"
      }
    } );
  
    $("#" + table + " tfoot input").keyup( function () {
      /* Filter on the column (the index) of this element */
      oTable.fnFilter( this.value, $("#" + table + " tfoot input").index(this) );
    } );
    
    /*
     * Support functions to provide a little bit of 'user friendlyness' to the textboxes in
     * the footer
     */
    $("#" + table + " tfoot input").each( function (i) {
      asInitVals[i] = this.value;
    } );
  
    $("#" + table + " tfoot input").focus( function () {
      if ( this.className == table + "_search_init" )
      {
        this.className = "";
        this.value = "";
      }
    } );
  
    $("#" + table + " tfoot input").blur( function (i) {
      if ( this.value == "" )
      {
        this.className = table + "_search_init";
        this.value = asInitVals[$("#" + table + " tfoot input").index(this)];
      }
    } );
  }
  
  /* ****************** */
  /* *** INITIALIZE *** */
  /* ****************** */
  
  /* connect form with subquery */
  /* TODO: need to improve! */
  
  $("table" ).each(function( n ) {
    if ($(this).attr('data-from-form')) {
      $('#' + $(this).attr('data-from-form') + ' #' + $(this).attr('data-from-field')).data('from-form', $(this).attr('data-from-form') );
      $('#' + $(this).attr('data-from-form') + ' #' + $(this).attr('data-from-field')).data('from-field', $(this).attr('data-from-field') );
      $('#' + $(this).attr('data-from-form') + ' #' + $(this).attr('data-from-field')).data('to-table', $(this).attr('data-to-table') );
      $('#' + $(this).attr('data-from-form') + ' #' + $(this).attr('data-from-field')).data('to-field', $(this).attr('data-to-field') );
    }
  });

  /* iterate through each form */

  $("form" ).each(function( n ) {
    /* loop and initialize each form in the page */
    init_form( $(this).attr('id') );
  });

  /* iterate through each table */

  $("table" ).each(function( n ) {
    /* loop and initialize each form in the page */
    if ($(this).attr('data-ajax-source')) {
      init_table($(this).attr('id'), $(this).attr('data-ajax-source'));
    }
  });

});