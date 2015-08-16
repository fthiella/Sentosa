<%class>
  has 'id';
</%class>
<%perl>
  use Sentosa::Objects;
  use Data::Dumper;

  my ($conn) = Sentosa::Objects::get_formconnection($.id, $.authenticated_user);
  print $conn->{db};
  print "<br>\n\n";
  print $conn->{source};
  print "<br>\n\n";
  
  my @columns = Sentosa::Objects::get_formcolumns($.id, $.authenticated_user);
  foreach my $column (@columns) {
    print $column->{col}, "\n";
  }
  print join(',', map { $_->{col} } @columns);
</%perl>