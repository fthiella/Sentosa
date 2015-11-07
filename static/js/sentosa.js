/*jslint browser: true*/
/*global $, jQuery, alert, console*/

"use strict";

var asInitVals = []; /* for datatables */

/* http://datatables.net/plug-ins/api/fnVisibleToColumnIndex */
/* TODO: next plugin is DEPRECATED */
jQuery.fn.dataTableExt.oApi.fnVisibleToColumnIndex = function (oSettings, iMatch) {
    return oSettings.oApi._fnVisibleToColumnIndex(oSettings, iMatch);
};

$.fn.formObject = function (obj) {
    obj = obj || {};
    $.each(this.serializeArray(), function (_, kv) {
        obj[kv.name] = kv.value;
    });
    return obj;
};

$(document).ready(function() {
  /* ************** */
  /* form functions */
  /* ************** */
    function actions(form, action1, action2) {

        switch (action1) {
        case undefined: break;
        case "save":
            if ($("#is_dirty", form).val() === "1") {
                /* SAVE */
                $.getJSON(form.attr('action'), $('.form-control', form).formObject({ button: "save" }), function(res) {
                    if (res["_status"] === "OK") {
                        $('input#is_dirty', form).val('');
                        
                        /* if pk and last insert id are defined, update the pk field */ 
                        if ((typeof res["pk"] !== 'undefined') && (typeof res["last_insert_id"] !== 'undefined')) {
                            $('input#'+res["pk"]).val(res["last_insert_id"]);
                        }
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
            $(".form-control", form).each(function () {
                this.value = "";
            });
            break;
        default:
            var pk_obj = {};
            form.attr('data-pk').split(",").forEach(function (item) {
                pk_obj[item] = $('input#' + item, form).val();
            });
            /* TODO: check is_dirty first! and is_dirty will have a unique name */
            $.getJSON(
                form.attr('action'),
                $('input#goto_record', form).formObject($.extend({}, pk_obj, { button: action1})),
                function(res) {
                    $.each(res, function(key, val) {
                        /* TODO: disable is_dirty, and don't always call change! */

                        /* if it's a select2 component add the option before setting the default value */
                        /* TODO: this looks more like an "hack" than real production code.. there's a lot to be fixed here */
                        if ($('#' + key, form).attr('class') === 'form-control select2-hidden-accessible') {
                            $('#' + key + ' option:selected', form).remove();
                            console.log($('#' + key, form).attr('data-json'));
                            $.getJSON(
                                $('#' + key, form).attr('data-json'),
                                { id: val },
                                function(res) {
                                    $('#' + key, form).append('<option value="'+res["results"][0]["id"]+'" selected>'+res["results"][0]["text"]+'</option>');
                                    $('#' + key, form).val(res["results"][0]["id"]).change();
                                }
                            );
                        } else {
                            $('#' + key, form).val(val).change();
                        }
                    });
                    $("#is_dirty", form).val(0);
                }
            );
        }
    }

    function init_form(form) {
        /* buttons management */
        $('button#save', form).click(function() { actions(form, 'save', undefined); });
        $('button#gotofirst', form).click(function() { actions(form, 'save', 'primo'); });
        $('button#indietro', form).click(function() { actions(form, 'save', 'indietro'); });
        $('button#avanti', form).click(function() { actions(form, 'save', 'avanti'); });
        $('button#ultimo', form).click(function() { actions(form, 'save', 'ultimo'); });
        $('button#insert', form).click(function() { actions(form, 'save', 'insert'); });
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

    /* ****************** */
    /* *** INITIALIZE *** */
    /* ****************** */

    /* loop and initialize each form in the page */

    $("form").each(function() {
        init_form($(this));
    });

    /* NEW FUNCTIONS */

    function init_table(table) {
        var aoColumnDefs = [];

        $("tfoot input", table).each(function (n) {

            var f = function (data, type, row) {
                    if (this.attr('data-link')) {
                        return '<a href="../' + this.attr('data-link') + '?_record='+ row[this.attr('data-link-id')] +'"">' + data + '</a>';
                    } else {
                        return data;
                    }
                };

            aoColumnDefs.push({
                "sName": $(this).attr('name'),
                "bVisible": ($(this).attr('type') || 'text') === 'text',
                "mRender": f.bind($(this)),
                "aTargets": [ n ]
            });
        });

        var oTable = table.dataTable({
                "bProcessing": true,
                "bServerSide": true,
                "sAjaxSource": table.attr("data-ajax-source"),
                "aoColumnDefs": aoColumnDefs,

                "oLanguage": {
                    "sLengthMenu":   "Mostra _MENU_ righe per pagina",
                    "sZeroRecords":  "Nessun risultato",
                    "sInfo":         "Da _START_ a _END_ di _TOTAL_ righe",
                    "sInfoEmpty":    "Nessun risultato",
                    "sInfoFiltered": "(_MAX_ totali)",
                    "sSearch":       "Cerca:"
                }
            });
        // console.dir(aoColumnDefs);

        /* SYNC: links form fields to table fields. Use a plugin like fieldsyc? */
        $("tfoot input[data-from-form]", table).each(function () {
            var to_field = $(this);

            $("#" + $(this).attr("data-from-form") + " input#" + $(this).attr("data-from-field")).change(function() {
                to_field.val($(this).val());
                to_field.trigger('keyup');
            });
        });

        $("tfoot input", table).keyup(function () {
            /* Filter on the column (the index) of this element */
            oTable.fnFilter(this.value, oTable.fnVisibleToColumnIndex($("tfoot input", table).index(this)));
        });

        /*
         * Support functions to provide a little bit of 'user friendlyness' to the textboxes in
         * the footer
         */
        $("tfoot input", table).focus(function () {
            if (this.className === "search_init") {
                this.className = "";
                this.value = "";
            }
        });

        $("tfoot input", table).blur(function () {
            if (this.value === "") {
                this.className = "search_init";
                this.value = $(this).attr('data-value');
            }
        });
    }

    /* initialize all tables */
    $('table[data-ajax-source]').each(function () {
        init_table($(this));
    });

    /* initialize all selects */
    /* https://github.com/select2/select2/issues/3116#issuecomment-102119431 */
    $('select').each(function () {
        $(this).select2({
            ajax: {
                url: $(this).attr('data-json'),
                dataType: "json",
                results: function (data) {
                    return {results: data};
                }
            }
        });
    });

});