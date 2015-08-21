<%class>
  has '_id';
  has 'hide_title' => (default => "0");
  has 'hide_top' => (default => "0");
  has 'hide_bottom' => (default => "0");
</%class>
<%init>
  use Sentosa::Objects;
  
  my ($select) = Sentosa::Objects::get_object($._id, 'query', $.authenticated_user);
  if (!$select) { $m->not_found(); }; # query not found
  
  my ($conn) = Sentosa::Objects::get_queryconnection($._id, $.authenticated_user);
  if (!$conn) {
    # connection not found - object does not exist, or user is not allowed, or user is not authenticated
    $m->not_found();
  };

  my $db = DBI->connect($conn->{db}, $conn->{username}, $conn->{password}) or die("connection to ".$conn->{db}." error.\n");
  
  my (@columns) = Sentosa::Objects::get_querycolumns($._id, $.authenticated_user);
  # TODO: always quote all identifiers, on every component not just here ^_^
  my @fields = map { $db->quote_identifier($_->{col}) } @columns;
</%init>
% # TODO: use a single tables.js script to initialize all datables in the page
<script type="text/javascript" charset="utf-8">
var asInitVals = new Array();

$(document).ready(function() {
  var oTable = $('#<% $._id %>').dataTable( {
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": "query_data?_id=<% $._id %>",

    "oLanguage": {
      "sLengthMenu":   "Mostra _MENU_ righe per pagina",
      "sZeroRecords":  "Nessun risultato",
      "sInfo":         "Da _START_ a _END_ di _TOTAL_ righe",
      "sInfoEmpty":    "Nessun risultato",
      "sInfoFiltered": "(_MAX_ totali)",
      "sSearch":       "Cerca:"
    }
  } );

  $("#<% $._id %> tfoot input").keyup( function () {
    /* Filter on the column (the index) of this element */
    oTable.fnFilter( this.value, $("#<% $._id %> tfoot input").index(this) );
  } );
  
    /*
   * Support functions to provide a little bit of 'user friendlyness' to the textboxes in
   * the footer
   */
  $("#<% $._id %> tfoot input").each( function (i) {
    asInitVals[i] = this.value;
  } );

  $("#<% $._id %> tfoot input").focus( function () {
    if ( this.className == "search_init_<% $._id %>" )
    {
      this.className = "";
      this.value = "";
    }
  } );

  $("#<% $._id %> tfoot input").blur( function (i) {
    if ( this.value == "" )
    {
      this.className = "search_init_<% $._id %>";
      this.value = asInitVals[$("#<% $._id %> tfoot input").index(this)];
    }
  } );
} );
</script>
%
% if ($.hide_title eq '0') {
<h1><% $select->{description} %></h1>
% }
%
%
<table id="<% $._id %>" class="table table-nomargin dataTable-custom table-bordered dataTable-scroller" data-ajax-source="json/<% $._id %>">
<thead>
  <tr>
% foreach my $col (map { $_->{caption} } @columns) {
    <th><% $col %></th>
% }
  </tr>
</thead>
<tbody>
  <tr>
    <td colspan="5" class="dataTables_empty">Loading data from server</td>
  </tr>
  </tbody>
<tfoot>
  <tr>
% foreach my $col (@fields) {
%   if ( $.hide_bottom eq '0' ) {
    <th><input type="text" name="<% $._id %>_search_<% $col %>" value="<% $col %>" class="search_init_<% $._id %>" /></th>
%   } else {
    <th><input type="hidden" name="<% $._id %>_search_<% $col %>" value="<% $col %>" class="search_init_<% $._id %>" /></th>
%   }
% }
  </tr>
</tfoot>
</table>
