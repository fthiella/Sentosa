<%class>
  has '_id';
  has 'table_link';
  has 'hide_title' => (default => "0");
  has 'hide_top' => (default => "0");
  has 'hide_bottom' => (default => "0");
</%class>
<%init>
  use JSON ();
  use Sentosa::Objects;

  my ($obj) = Sentosa::Objects::get_object($._id, 'query', $m->session->{auth_id});
  if (!$obj) { $m->not_found(); }; # form not found
  
  my $columns = JSON->new->utf8->decode($obj->{def});

  # TODO: always quote all identifiers, on every component not just here ^_^
  my @fields = map { $_->{col} } @{$columns};
</%init>
% if ($.hide_title eq '0') {
<h1><% $obj->{description} %></h1>
% }
<table id="<% $._id %>" class="table table-nomargin dataTable-custom table-bordered dataTable-scroller" data-ajax-source="query_data?_id=<% $._id %>">
<thead>
  <tr>
% foreach my $col (map { $_->{caption} } @{$columns}) {
    <th><% $col %></th>
% }
  </tr>
</thead>
<tbody>
  <tr>
    <td colspan="6" class="dataTables_empty">Loading data from server</td>
  </tr>
  </tbody>
<tfoot>
  <tr>
% foreach my $col (@fields) {
%   my $data_link;
%   if (($.table_link) && ($col eq $.table_link->{to_field})) {
%     $data_link = 'data-from-form="'. $.table_link->{from_form} .'" data-from-field="'. $.table_link->{from_field} .'"';
%   } else {
%     $data_link = "";
%   }
%   if ( $.hide_bottom eq '0' ) {
    <th><input type="text" name="<% $._id %>_search_<% $col %>" value="<% $col %>" data-value="<% $col %>" <% $data_link %> class="search_init" /></th>
%   } else {
    <th><input type="hidden" name="<% $._id %>_search_<% $col %>" value="<% $col %>" data-value="<% $col %>" <% $data_link %> class="search_init" /></th>
%   }
% }
  </tr>
</tfoot>
</table>
