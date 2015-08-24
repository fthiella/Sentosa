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
  use feature qw( switch );
  use Poet qw($log);
  use Sentosa::Objects;

  my ($conn) = Sentosa::Objects::get_formconnection($._id, $m->session->{auth_id});

  if (!$conn) {
    # connection not found - object does not exist, or user is not allowed, or user is not authenticated
    $m->not_found();
  };
  
  # create $db connection to the database referred to the form (Apache::DBI should take care of not creating the same connection again)

  my $db = DBI->connect($conn->{db}, $conn->{username}, $conn->{password}) or die("connection to ".$conn->{db}." error.\n");
  my $sth;
  # TODO: what if the primary key is not a single field?
  my $pk = $.args->{ $conn->{pk} };

  my @all_columns = Sentosa::Objects::get_formcolumns($._id, $m->session->{auth_id});
  my $csv_columns = join(',', map { $_->{col} } @all_columns);
  dc($csv_columns);

  #
  my @columns = ();
  my @values = ();
  
  foreach my $col (@all_columns) {
    # TODO: primary key is not always a single field
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
  
  my %h = ();
  if ($query =~ /^SELECT/) {
    $sth = $db->prepare($query);
    $sth->execute(@params);
    my $values = $sth->fetchrow_hashref();
    $sth->finish();

    if ($$values{ $conn->{pk}} ) { # pk is defined so the query succeeded
      foreach my $col (@all_columns) {
        $h{ $col->{col} } = $$values{ $col->{col} };
      }
      $m->send_json( \%h );
    }
  } else {
    $sth = $db->prepare($query);
    $sth->execute(@params);
    $sth->finish();

    $h{_status} = 'OK'; # TODO: is this really a good idea? Anyway, need to check status of the query, need to get LAST_INSERT_ID
    $m->send_json( \%h );
  }
</%init>