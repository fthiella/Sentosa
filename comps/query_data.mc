<%flags>
  extends => 'Base.mp';
</%flags>
<%class>
  has 'iDisplayStart';
  has 'iDisplayLength';
  has 'iColumns';

  has 'sEcho';
</%class>
<%init>
  use JSON;
  use Data::Dumper;
  
  print STDERR Dumper($.args);
    
  my $sth = $samdb->prepare(
    'SELECT
       o.id, o.description, o.recordsource,
       d.database, d.username, d.password
     FROM
       am_objects o INNER JOIN am_databases d ON o.database=d.id
     WHERE objectType=? AND objectName=?'
  );
  $sth->execute('Query', $m->path_info());
  my $obj = $sth->fetchrow_hashref() || die("Query not found!");
  $sth->finish();

  # -----------------------------------------------------------------
  # get field names if required
  # -----------------------------------------------------------------
  my @fields = ();
  if ($$obj{recordsource} =~ /\[query_details\]/) {
    # get column details from am_query_details table
    $sth = $samdb->prepare('SELECT
                            sourcecolumn,
                            link
                          FROM
                            am_query_details
                          WHERE
                            objectid=?
                          ORDER BY
                            sortorder');
    $sth->execute($$obj{id});
    my $i=0;
    while (my $ref = $sth->fetchrow_hashref()) {
      push @fields, [$i, $ref->{'sourcecolumn'}, 0, 0, $ref->{'link'}];
      $i++;
    }
    $sth->finish();
  }
  my $query_details = join(', ', map { ${$_}[1] } @fields); # creates a comma separated list of fields
  my @links = map { [${$_}[0], ${$_}[4] ] } grep { ${$_}[4] ne '' } @fields;
  $$obj{recordsource} =~ s/\[query_details\]/$query_details/;
  # -----------------------------------------------------------------
  
  # create $dbh connection to the database referred to the form (Apache::DBI should take care of not creating the same connection again)
  my $dbh = DBI->connect($$obj{database}, $$obj{username}, $$obj{password}) or die("connection to $$obj{database} error.\n");

  my @active_conditions = ();
  my @active_filters = ();
  #################################################################
  # check if some sSearch_n field has a value
  # ... cache columns somehow? but now we don't care!
  my @sSearch = ();
  foreach (grep {/^sSearch_\d+/} keys $.args) {
    if ($.args->{$_} ne "") {
      push @sSearch, $_ =~ /sSearch_(\d+)/;
    }
  }
  if (@sSearch) {
    my $sthc = $dbh->prepare($$obj{recordsource}.' LIMIT 1');
    $sthc->execute();
    
    foreach (@sSearch) {
      push @active_conditions, $sthc->{NAME}->[$_].' LIKE CONCAT(?, \'%\')'; # in MySQL casts are often not necessary... what about others dbms?
      push @active_filters, $.args->{"sSearch_$_"};
    }
  }
  #################################################################
  
  my $query          = $$obj{recordsource};
  my $query_filt     = $$obj{recordsource};
  if (@active_conditions) { $query_filt = "$query WHERE " . join ' AND ', @active_conditions; }

  my $query_cnt_all  = "SELECT COUNT(*) AS rows FROM ($query) q\n";
  my $query_cnt_filt = "SELECT COUNT(*) AS rows FROM ($query_filt) q\n";
  print STDERR $query_cnt_filt, "\n";

  #### get number of unfiltered rows ####

  $sth = $dbh->prepare($query_cnt_all);
  $sth->execute();
  my @riga = $sth->fetchrow_array();
  my $iTotalRecords = $riga[0];
  $sth->finish();

  #### get number of filtered rows ####

  $sth = $dbh->prepare($query_cnt_filt);
  $sth->execute(@active_filters);
  @riga = $sth->fetchrow_array();
  my $iTotalDisplayRecords = $riga[0];
  $sth->finish();

  #### get rows ####

  my @rows;

  # LIMIT and OFFSET depends on the database
  if ($$obj{database} =~ /^DBI:mysql:/) {
    $sth = $dbh->prepare("$query_filt LIMIT ".int($.iDisplayStart).", ".int($.iDisplayLength));
  } elsif ($$obj{database} =~ /^DBI:Pg:/) {
    $sth = $dbh->prepare("$query_filt LIMIT ".int($.iDisplayLength)." OFFSET ".int($.iDisplayStart));
  }
  $sth->execute(@active_filters);

  print STDERR "Esegui: $query_filt LIMIT ".int($.iDisplayStart)." OFFSET ".int($.iDisplayLength), "\n";

  while (my @row = $sth->fetchrow_array()) {
    foreach my $field_num (@links) {
      $row[${$field_num}[0]] = '<a href="'.${$field_num}[1].'&record='.$row[${$field_num}[0]].'">'.$row[${$field_num}[0]].'</a>';
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
  print encode_json \%src;
</%perl>
