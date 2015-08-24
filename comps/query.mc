<%class>
  has '_id';
  has 'table_link';
  has 'hide_title' => (default => "0");
  has 'hide_top' => (default => "0");
  has 'hide_bottom' => (default => "0");
</%class>
<%init>
  use Sentosa::Objects;
  
  my ($select) = Sentosa::Objects::get_object($._id, 'query', $m->session->{auth_id});
  if (!$select) { $m->not_found(); }; # query not found
  
  my ($conn) = Sentosa::Objects::get_queryconnection($._id, $m->session->{auth_id});
  if (!$conn) {
    # connection not found - object does not exist, or user is not allowed, or user is not authenticated
    $m->not_found();
  };

  my $db = DBI->connect($conn->{db}, $conn->{username}, $conn->{password}) or die("connection to ".$conn->{db}." error.\n");
  
  my (@columns) = Sentosa::Objects::get_querycolumns($._id, $m->session->{auth_id});
  # TODO: always quote all identifiers, on every component not just here ^_^
  my @fields = map { $_->{col} } @columns;
</%init>
% if ($.hide_title eq '0') {
<h1><% $select->{description} %></h1>
% }
<table id="<% $._id %>" class="table table-nomargin dataTable-custom table-bordered dataTable-scroller" data-ajax-source="query_data?_id=<% $._id %>" <% $.table_link %>>
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
    <th><input type="text" name="<% $._id %>_search_<% $col %>" value="<% $col %>" class="<% $._id %>_search_init" /></th>
%   } else {
    <th><input type="hidden" name="<% $._id %>_search_<% $col %>" value="<% $col %>" class="<% $._id %>_search_init" /></th>
%   }
% }
  </tr>
</tfoot>
</table>
