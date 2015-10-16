package Sentosa::Db;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

use feature "switch";

sub whereFilter {
  my ($col, $searchcriteria, $dbms) = @_;

  my $ck;

  given ($dbms) {

    when ('SQLite') {
      given ($searchcriteria) {
        when ('=')    { $ck = "$col=?"; }
        when ('LIKE') { $ck = "$col LIKE ? || '%'"; }
        when ('SUB')  { $ck = "$col LIKE '%' || ? || '%'"; }
        when (undef)  { $ck = "$col LIKE ? || '%'"; }
      }
    }

    when ('Pg') {
      given ($searchcriteria) {
        when ('=')    { $ck = "$col=?"; }
        when ('LIKE') { $ck = "$col LIKE ? || '%'"; }
        when ('SUB')  { $ck = "$col LIKE '%' || ? || '%'"; }
        when (undef)  { $ck = "$col LIKE ? || '%'"; }
      }
    }

    when ('mysql') {
      given ($searchcriteria) {
        when ('=')    { $ck = "$col=?"; }
        when ('LIKE') { $ck = "$col LIKE CONCAT(?,'%')"; }
        when ('SUB')  { $ck = "$col LIKE CONCAT('%',?,'%')"; }
        when (undef)  { $ck = "$col LIKE CONCAT(?,'%')"; }
      }
    }
  }

  return $ck;
}

sub limitFilter {
  my ($start, $length, $dbms) = @_;
  # TODO: check this sub - I'm not sure it's correct, haven't tested it yet

  my $limit1;
  my $limit2;

  if (!$start) { $start=0; }
  if (!$length) { $length=99; }

  given ($dbms) {
    when ('SQLite') { $limit2 = " LIMIT $start, $length"; }
    when ('Pg')     { $limit2 = " LIMIT $length OFFSET $start"; }
    when ('mysql')  { $limit2 = " LIMIT $start, $length"; }
  }

  return ($limit1, $limit2);
}

sub pk_conditions {
  my ($pk_columns, $pk_conditions, $move) = @_;

  my %o = (
    'goto'      => '=',
    'forwards'  => '>',
    'backwards' => '<',
  );

  my @pk_conditions;
  my @pk_conditions_data;

  if ($o{$move}) {

    for (my $i= (0+@{$pk_columns}) - 1; $i>=0; $i--) {
      my @or_conditions = (
        (map { $_ . '=?' } @{$pk_columns}[0..$i-1]),
        (@{$pk_columns}[$i] . $o{$move} . '?')
      );

      push @pk_conditions, '(' . join(' AND ', @or_conditions) . ')';
      push @pk_conditions_data, @{$pk_conditions}[0..$i];

      if ($move eq 'goto') { last; }
    }

  }

  return (
    (@pk_conditions)?'(' . join(' OR ', @pk_conditions) . ')':undef,
    \@pk_conditions_data
  );
}

sub selectQuery {
  my ($source, $columns, $order, $goto, $start, $length, $dbms) = @_;

  # get all column names from the columns array
  my @sc = map { $_->{col} } @{$columns}; # TODO: better to use column qualifier

  # Filter: filter table (for example by username)
  # Search: search within filtered table

  # - grep gets all columns that have to be filtered
  # - map creates "field=?" or "fields LIKE ?" etc.

  my @filter = map { whereFilter($_->{col}, $_->{searchcriteria}, $dbms) } grep { defined $_->{filter} } @{$columns};
  my @search = map { whereFilter($_->{col}, $_->{searchcriteria}, $dbms) } grep { defined $_->{search} } @{$columns};

  my @filter_data =   (map { $_->{filter} }              grep { defined $_->{filter} } @{$columns});
  my @filter_search = (map { $_->{search} }              grep { defined $_->{search} } @{$columns});
  my @order_by =      (map { $_->{col}." ".$_->{order} } grep { defined $_->{order}  } @{$columns});
  my @order_by_pk =   (map { $_->{col}." $order" }       grep { defined $_->{pk}     } @{$columns});


  my ($pk_conditions, $pk_conditions_data) = pk_conditions(
    [map { $_->{col} } grep { defined $_->{pk} } @{$columns}],
    $goto->{pk},
    $goto->{move}
  );

  print dh $pk_conditions;

  my ($limit1, $limit2) = limitFilter($start, $length, $dbms);

  return (
    'query' => 'SELECT '.join(',', @sc)." FROM $source". (((@filter) || (defined $pk_conditions))?' WHERE '.join(' AND ', grep defined, (@filter, $pk_conditions)):undef),
    'query_data' => [@filter_data, @{$pk_conditions_data}],

    'query_search' => 'SELECT '.join(',', @sc)." FROM $source". (((@filter) || (defined $pk_conditions) || (@search))?' WHERE '.join(' AND ', grep defined, (@filter, $pk_conditions, @search)):undef),
    'query_search_data' => [@filter_data, @{$pk_conditions_data}, @filter_search],

    'query_limit' =>
      'SELECT '.$limit1.' '.join(',', @sc).
      " FROM $source". (((@filter) || (defined $pk_conditions) || (@search))?' WHERE '.join(' AND ', grep defined, (@filter, $pk_conditions, @search)):undef).
      " ORDER BY ".join(',', @order_by, @order_by_pk).
      "$limit2",
    'query_limit_data' => [@filter_data, @{$pk_conditions_data}, @filter_search]
  );
}

1;
