<%doc>
Operazioni sul database, chiamate dal form ajax: lettura records, spostamento, etc.
</%doc>
<%class>
  has '_id'; # id of the object
  has 'button';
  has 'id'; # primary key
  # TODO: what if the primary key name is not id? and what if the primary key is not even a single field?
</%class>
<%flags>
  extends => 'Base.mp';
</%flags>
<%init>
  use JSON;
  use feature qw( switch );
  use Poet qw($log);
  use Sentosa::Objects;

  my ($conn) = Sentosa::Objects::get_formconnection($._id, $.authenticated_user);
  
  $log->error("_id=".$._id." id=".$.id);
  dc($conn);
  
  # create $db connection to the database referred to the form (Apache::DBI should take care of not creating the same connection again)

  my $db = DBI->connect($conn->{db}, $conn->{username}, $conn->{password}) or die("connection to ".$conn->{db}." error.\n");
  my $sth;

  my @all_columns = Sentosa::Objects::get_formcolumns($._id, $.authenticated_user);
  my $csv_columns = join(',', map { $_->{col} } @all_columns);

  #
  my @columns = ();
  my @values = ();
  
  foreach my $col (@all_columns) {
    # TODO: primary key is not always id, check the actual name!
    unless ($col->{col} =~ /id/) {        
      push @columns, $col->{col};
      push @values, $.args->{ $col->{col} };
    }
  }

  my $query;
  my @params = ();
  
  given ($.button)
  {
    # action SAVE
    when ('save') {
      # UPDATE it if ID is given, otherwise INSERT it
    
      if ($.id ne '') {
        push @values, $.id;
        $query='UPDATE '.$conn->{source}.' SET '.join('=?,', @columns).'=? WHERE '.$conn->{orderkey}.'=?';
        @params=@values;
        # if succeded, set is_dirty to zero! if not, raise an error?
      } else {
        $query='INSERT INTO '.$conn->{source}.' ('.join(',', @columns).') VALUES ('.substr('?,'x scalar @values, 0, -1).')';
        @params=@values;
      }

    }

    when ('primo') {
      if ($.args->{'goto_record'} ne '') {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' WHERE id=? ORDER BY '.$conn->{orderkey}.' LIMIT 1';
        push @params, $.args->{'goto_record'};
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' ORDER BY '.$conn->{orderkey}.' LIMIT 1';
      }
    }
    when ('ultimo') {
      $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' ORDER BY '.$conn->{orderkey}.' DESC LIMIT 1';
    }
    when ('indietro') {
      # se nullo vai all'ultimo
      if ($.id eq '') {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' ORDER BY '.$conn->{orderkey}.' DESC LIMIT 1';
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' WHERE '.$conn->{orderkey}.'<? ORDER BY '.$conn->{orderkey}.' DESC LIMIT 1';
        push @params, $.id;
      }
    }
    when ('avanti') {
      # se id nullo vai all'ultimo
      if ($.id eq '') {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' ORDER BY '.$conn->{orderkey}.' DESC LIMIT 1';
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' WHERE '.$conn->{orderkey}.'>? ORDER BY '.$conn->{orderkey}.' LIMIT 1';
        push @params, $.id;
      }
    }
   
  }
  
  my %h = ();
  if ($query =~ /^SELECT/) {
    print STDERR $query, "\n";
    $sth = $db->prepare($query);
    $sth->execute(@params);
    my $values = $sth->fetchrow_hashref();
    $sth->finish();

    foreach my $col (@all_columns) {
        $h{ $col->{col} } = $$values{ $col->{col} };
    }
    $h{_status} = 'OK';
    my $json = encode_json \%h;
  } else {
    $sth = $db->prepare($query);
    $sth->execute(@params);
    $sth->finish();

    $h{_status} = 'OK';
    my $json = encode_json \%h; 
  }
  
  my $json = encode_json \%h;
  print $json;
  $log->error($json);
</%init>