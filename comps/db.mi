<%doc>
Operazioni sul database, chiamate dal form ajax: lettura records, spostamento, etc.
</%doc>
<%class>
  has '_id'; # id of the object
  has 'button';
</%class>
<%flags>
  extends => undef;
</%flags>
<%init>
  use feature qw( switch );
  use Poet qw($log);
  use JSON ();
  use Sentosa::Objects;
  
  my ($form) = Sentosa::Objects::get_object($._id, 'form', $m->session->{auth_id});
  if (!$form) { $m->not_found(); }; # form not found
  
  my @all_columns = @{ JSON->new->utf8->decode($form->{def}) };

  # create $db connection to the database referred to the form (Apache::DBI should take care of not creating the same connection again)

  my $db = DBI->connect($form->{db}, $form->{username}, $form->{password}) or die("connection to ".$form->{db}." error.\n");
  my $sth;
  
  # TODO: what if the primary key is not a single field?
  my @pk_columns = split ',', $form->{pk};
  my @pk_values = map { $.args->{$_} } @pk_columns;
  my $pk_given; if (grep /^$/, @pk_values) { $pk_given = 0; } else { $pk_given = 1; }; # more perlish? but now it's fine
  
  ####################################################################
  # create condition for PREVIOUS/NEXT supporting multiple-fields keys
  ####################################################################

  my @pk_condition = ();
  my @pk_condition_values = ();

  for (my $i=scalar @pk_columns -1; $i>=0; $i--) {
    my @or_condition = map { $_ . '=?' } @pk_columns[0..$i-1];

    if ($.button eq 'avanti') {
      push @or_condition, @pk_columns[$i] . '>?';
    } elsif ($.button eq 'indietro') {
      push @or_condition, @pk_columns[$i] . '<?';
    };

    push @pk_condition, '(' . join(' AND ', @or_condition) . ')';
    
    push @pk_condition_values, map { $.args->{$_} } @pk_columns[0..$i];
  }

  ####################################################################

  my $csv_columns = join(',', map { $_->{col} } @all_columns);

  #
  my @columns = ();
  my @values = ();
  
  # get all column names, and POSTed values
  
  foreach my $col (@all_columns) {
    # TODO: how to distinguish between UPDATE and INSERT ? Save on a new record is INSERT, otherwise UPDATE. Client side?
    # unless (grep {$_ eq $col->{col}} split ',', $form->{pk}) { # skips primary keys
      push @columns, $col->{col};
      push @values, $.args->{ $col->{col} };
    # }
  }
  
  my @pk_params = ();

  my $query;
  my @params = ();

  given ($.button)
  {
    # action SAVE
    when ('save') {
      # UPDATE it if ID is given, otherwise INSERT it
    
      if ($pk_given) {
        $query='UPDATE '.$form->{source}.' SET '. join('=?,', @columns) .'=? WHERE ' . join(' AND ', map { $_ . '=?' } @pk_columns );
        push @params, @values;
        push @params, @pk_values;
      } else {
        # TODO: add given keys, if any!
        $query='INSERT INTO '.$form->{source}.' ('.join(',', @columns).') VALUES ('.substr('?,'x scalar @values, 0, -1).')';
        @params=@values;
      }
      
      print dh $query;
      return;

    }

    when ('primo') {
      if ($.args->{'goto_record'} ne '') {
        $query=
          'SELECT '.$csv_columns.
          ' FROM '.$form->{source}.
          ' WHERE '.join(' AND ', map { $_ . '=?' } @pk_columns ).
          ' LIMIT 1'; # no order by? I think there's no need
        push @params, split ',', $.args->{'goto_record'}; # TODO: what if a key contains a comma? Not common but can happen
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$form->{source}.' ORDER BY '. $form->{pk}.' LIMIT 1';
      }
    }
    when ('ultimo') {
      $query='SELECT '.$csv_columns.' FROM '.$form->{source}.' ORDER BY '. join(',', map { $_ . ' DESC' } @pk_columns).' LIMIT 1';
    }
    when ('indietro') {
      if ($pk_given) {
        $query='SELECT '.$csv_columns.' FROM '.$form->{source}.' WHERE '. join(' OR ', @pk_condition) .' ORDER BY '.join(',', map { $_ . ' DESC' } @pk_columns).' LIMIT 1';
        push @params, @pk_condition_values;
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$form->{source}.' ORDER BY '.join(',', map { $_ . ' DESC' } @pk_columns).' LIMIT 1';
      }
    }
    when ('avanti') {
      if ($pk_given) {
        $query='SELECT '.$csv_columns.' FROM '.$form->{source}.' WHERE '. join(' OR ', @pk_condition) .' ORDER BY '.join(',', map { $_ . ' ASC' } @pk_columns).' LIMIT 1';
        push @params, @pk_condition_values;
      } else {
        $query='SELECT '.$csv_columns.' FROM '.$form->{source}.' ORDER BY '.join(',', map { $_ . ' ASC' } @pk_columns).' LIMIT 1';
      }
    }
   
  }
  
  my %h = ();
  if ($query =~ /^SELECT/) {
    $sth = $db->prepare($query);
    $sth->execute(@params);
    my $values = $sth->fetchrow_hashref();
    $sth->finish();

    if ( $values ) { # TODO: check somehow if the query succeeded
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