<%flags>
  extends => 'Base.mp';
</%flags>
<%class>
  has '_id';

  has 'iDisplayStart';
  has 'iDisplayLength';
  has 'iColumns';

  has 'sEcho';
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
  
  my (@columns) = Sentosa::Objects::get_querycolumns($._id, $.authenticated_user);
  my @fields = map { $_->{col} } @columns;
  my @links = map { $_->{link} } @columns;
  
  my $h = DBI->connect($conn->{db}, $conn->{username}, $conn->{password}) or die("connection to ".$conn->{db}." error.\n");

  my @active_conditions = ();
  my @active_filters = ();
  
  # check if some sSearch_n field has a value
  # TODO: which kind of search do we have to apply?
  # TODO: if there are more datatables on the same page, is this handled correctly?
  my @sSearch = ();
  foreach (grep {/^sSearch_\d+/} keys $.args) {
    if ($.args->{$_} ne "") {
      push @sSearch, $_ =~ /sSearch_(\d+)/;
    }
  }

  foreach (@sSearch) {
    # push @active_conditions, @fields[$_]." LIKE CONCAT(?, '%')"; # in MySQL casts are often not necessary... what about others dbms?
    push @active_conditions, @fields[$_]." LIKE ? || '%'"; # for SQLite, only for string fields
    push @active_filters, $.args->{"sSearch_$_"};
  }

#  #################################################################
  
  my $query          = "SELECT ".join(',', @fields)." FROM ".$select->{source};
  my $query_filt     = "SELECT ".join(',', @fields)." FROM ".$select->{source};
  if (@active_conditions) { $query_filt = "$query WHERE " . join ' AND ', @active_conditions; }

  my $query_cnt_all  = "SELECT COUNT(*) AS rows FROM ($query) q\n";
  my $query_cnt_filt = "SELECT COUNT(*) AS rows FROM ($query_filt) q\n";

  #### get number of unfiltered rows ####
  
  my $sth;

  # get number of total rows, and number of total filtered rows
  my ($iTotalRecords) = $h->selectrow_array($query_cnt_all);
  my ($iTotalDisplayRecords) = $h->selectrow_array($query_cnt_filt, undef, @active_filters);

  #### get rows ####

  my @rows;

  # TODO: LIMIT and OFFSET depends on the database, is there a native DBI solution for this?
  if ($h->{Driver}->{Name} =~ /^mysql$|^SQLite$/) {
    $sth = $h->prepare("$query_filt LIMIT ".int($.iDisplayStart).", ".int($.iDisplayLength));
  } elsif ($h->{Driver}->{Name} =~ /^Pg$/) {
    $sth = $h->prepare("$query_filt LIMIT ".int($.iDisplayLength)." OFFSET ".int($.iDisplayStart));
  }
  $sth->execute(@active_filters);

  while (my @row = $sth->fetchrow_array()) {
    for (my $index=0; $index<=$#links; $index++) {
      if ($links[$index]) {      
        $row[$index] = qq{<a href="$links[$index]&_record=$row[$index]">$row[$index]</a>};
      }
    }
    push @rows, \@row;
  }

  my %src = (
    sEcho => $.sEcho,
    iTotalRecords => $iTotalRecords,
    iTotalDisplayRecords => $iTotalDisplayRecords,
    aaData => \@rows
  );
</%init>
<%perl>
 $m->send_json( \%src );
</%perl>
