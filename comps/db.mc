<%doc>
Operazioni sul database, chiamate dal form ajax: lettura records, spostamento, etc.
</%doc>
<%class>
  has '_id'; # id of the object
  has 'button';
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

  if (!$conn) {
    die('undef connection ('.$._id.', '.$.authenticated_user.')');
  }
  
  # create $db connection to the database referred to the form (Apache::DBI should take care of not creating the same connection again)

  my $db = DBI->connect($conn->{db}, $conn->{username}, $conn->{password}) or die("connection to ".$conn->{db}." error.\n");
  my $sth;
  # TODO: what if the primary key is not a single field?
  my $pk = $.args->{ $conn->{pk} };

  my @all_columns = Sentosa::Objects::get_formcolumns($._id, $.authenticated_user);
  my $csv_columns = join(',', map { $_->{col} } @all_columns);
  dc($csv_columns);

  #
  my @columns = ();
  my @values = ();
  
  foreach my $col (@all_columns) {
    # TODO: primary key is not always id, check the actual name!
    unless ($col->{col} eq $conn->{pk}) {
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
    
      if ($pk ne '') {
        push @values, $pk;
        $query='UPDATE '.$conn->{source}.' SET '.join('=?,', @columns).'=? WHERE '.$conn->{pk}.'=?';
        @params=@values;
        # if succeded, set is_dirty to zero! if not, raise an error?
      } else {
        $query='INSERT INTO '.$conn->{source}.' ('.join(',', @columns).') VALUES ('.substr('?,'x scalar @values, 0, -1).')';
        @params=@values;
      }

    }

    when ('primo') {
      if ($.args->{'goto_record'} ne '') {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' WHERE '.$conn->{pk}.'=? ORDER BY '.$conn->{pk}.' LIMIT 1';
        push @params, $.args->{'goto_record'};
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' ORDER BY '.$conn->{pk}.' LIMIT 1';
      }
    }
    when ('ultimo') {
      $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' ORDER BY '.$conn->{pk}.' DESC LIMIT 1';
    }
    when ('indietro') {
      # se nullo vai all'ultimo
      if ($pk eq '') {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' ORDER BY '.$conn->{pk}.' DESC LIMIT 1';
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' WHERE '.$conn->{pk}.'<? ORDER BY '.$conn->{pk}.' DESC LIMIT 1';
        push @params, $pk;
      }
    }
    when ('avanti') {
      # se id nullo vai all'ultimo
      if ($pk eq '') {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' ORDER BY '.$conn->{pk}.' DESC LIMIT 1';
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$conn->{source}.' WHERE '.$conn->{pk}.'>? ORDER BY '.$conn->{pk}.' LIMIT 1';
        push @params, $pk;
      }
    }
   
  }
  
  dc($query);
  
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