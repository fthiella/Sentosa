var asInitVals = new Array(); /* for datatables */

$(document).ready(function()
{
  /* ************** */
  /* form functions */
  /* ************** */
  function actions(form, action1, action2) {

    switch (action1) {
      case "save":
        if ($("#is_dirty", form).val()=="1") {
          /* SAVE */
          $.getJSON(form.attr('action'), 'button=save&' + $('.form-control', form).serialize(), function(res) {
            if (res["_status"] === "OK") {
              $('input#is_dirty', form).val('');
              /* proceed with next action */
              actions(form, action2, undefined);
            } else {
              alert("Couldn't save current record");
            }
          });
        } else {
          actions(form, action2, undefined);
        }
        break;
      case "insert":
        
        $(".form-control", form).each( function (n) {
          this.value="";
        });
        break;
      default:
        /* TODO: check is_dirty first! and is_dirty will have a unique name */
        $.getJSON(
          form.attr('action'),
          'button=' + action1 + '&' +
          $('input#id', form).serialize()+ '&' +
          $('input#goto_record', form).serialize(),
          function( res ) {
            $.each( res, function( key, val ) { /* TODO: disable is_dirty, and don't always call change! */
              $('#'+key, form).val(val).change();
            });
            $("#is_dirty", form).val(0);
          }
        )
    }
  }

  function init_form(form) {
      /* buttons management */
      $('button#save', form).click(function()      { actions(form, 'save', undefined); });
      $('button#gotofirst', form).click(function() { actions(form, 'save', 'primo'); });
      $('button#indietro', form).click(function()  { actions(form, 'save', 'indietro'); });
      $('button#avanti', form).click(function()    { actions(form, 'save', 'avanti'); });
      $('button#ultimo', form).click(function()    { actions(form, 'save', 'ultimo'); });
      $('button#insert', form).click(function()    { actions(form, 'save', 'insert'); });
      /* TODO: undo, and delete! */

      /* GOTO_RECORD on Change */
      $('input#goto_record', form).change(function() {
        actions(form, 'primo');
      });

      /* CHANGE EDIT DATA */
      form.change(function() {
        /* intercepts a edit/change on the current form, and sets is_dirty to true */
        $("#is_dirty", form).val(1);
      }); 

      /* go to the first record, or to the goto_record if specified */
      actions(form, 'primo');
  }

  var fields = new Array();

  /* ****************** */
  /* *** INITIALIZE *** */
  /* ****************** */

  /* loop and initialize each form in the page */

  $("form").each(function( n ) {
    init_form($(this));
  });

  /* NEW FUNCTIONS */

  function init_table(table) {
    var oTable = table.dataTable( {
      "bProcessing": true,
      "bServerSide": true,
      "sAjaxSource": table.attr("data-ajax-source"),
  
      "oLanguage": {
        "sLengthMenu":   "Mostra _MENU_ righe per pagina",
        "sZeroRecords":  "Nessun risultato",
        "sInfo":         "Da _START_ a _END_ di _TOTAL_ righe",
        "sInfoEmpty":    "Nessun risultato",
        "sInfoFiltered": "(_MAX_ totali)",
        "sSearch":       "Cerca:"
      }
    } );

    /* links form fields to table fields. Use a plugin like fieldsyc? */
    $("tfoot input[data-from-form]", table).each( function (n) {
      var to_field = $(this);

      $("#" + $(this).attr("data-from-form") + " input#" + $(this).attr("data-from-field")).change(function(n) {
        to_field.val($(this).val());
        to_field.trigger('keyup');
      })
    });

    $("tfoot input", table).keyup( function () {
      /* Filter on the column (the index) of this element */
      oTable.fnFilter( this.value, $("tfoot input", table).index(this) );
    } );

    /*
     * Support functions to provide a little bit of 'user friendlyness' to the textboxes in
     * the footer
     */
    $("tfoot input", table).focus( function () {
      if ( this.className == "search_init" )
      {
        this.className = "";
        this.value = "";
      }
    } );

    $("tfoot input", table).blur( function (i) {
      if ( this.value == "" )
      {
        this.className = table + "search_init";
        this.value = $(this).attr('data-value');
      }
    } );
  }

  /* initialize all tables */
  $('table[data-ajax-source]').each(function (n) {
    init_table($(this));
  });

});