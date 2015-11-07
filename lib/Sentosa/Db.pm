package Sentosa::Db;

use strict;
use warnings;
our $VERSION = '0.10';

#our $SELF = __PACKAGE__->new;

my $DBMS_MAP = {
    'SQLite' => {
        DELIMITER  => ',',
        QUOTE      => '"',
        SEARCH_MAP => {
            '='    => '%s=?',
            'LIKE' => '%s LIKE ? || \'%\'',
            'SUB'  => '%s LIKE \'%\' || ? || \'%\'',
        },
        LIMIT => 'LIMIT %1$d, %2$d',
    },
    'Pg' => {
        DELIMITER  => ',',
        QUOTE      => '"',
        SEARCH_MAP => {
            '='    => '%s=?',
            'LIKE' => '%s LIKE ? || \'%\'',
            'SUB'  => '%s LIKE \'%\' || ? || \'%\'',
        },
        LIMIT => 'LIMIT %2$d OFFSET %1$d',
    },
    'mysql' => {
        DELIMITER    => ',',
        QUOTE      => '`',
        SEARCH_MAP => {
            '='    => '%s=?',
            'LIKE' => '%s LIKE CONCAT(?,\'%\')',
            'SUB'  => '%s LIKE CONCAT(?,\'%\')',
        },
        LIMIT => 'LIMIT %1$d, %2$d',
    },
};

sub whereFilter {
  my ($col, $searchcriteria, $dbms) = @_;

  return sprintf $DBMS_MAP->{$dbms}->{SEARCH_MAP}->{$searchcriteria // 'SUB'}, $col;
}

sub limitFilter {
  my ($start, $length, $dbms) = @_;

  return (
    (sprintf $DBMS_MAP->{$dbms}->{TOP}, $start, $length),
    (sprintf $DBMS_MAP->{$dbms}->{LIMIT}, $start // 0, $length // 99)
  );
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

  if ($o{$move // ''}) {

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

  my $C = $DBMS_MAP->{$dbms};

  # get all column names from the columns array
  my @sc = map {
    $C->{QUOTE} . $source . $C->{QUOTE}.
    '.'.
    $C->{QUOTE} . $_->{col} . $C->{QUOTE}
  } grep { defined $_->{col} } @{$columns};

  # Filter: filter table (for example by username)
  # Search: search within filtered table

  # - grep gets all columns that have to be filtered
  # - map creates "field=?" or "fields LIKE ?" etc.

  my @filter = map { whereFilter($C->{QUOTE}.$source.$C->{QUOTE}.'.'.$C->{QUOTE}.$_->{col}.$C->{QUOTE}, $_->{searchcriteria}, $dbms) } grep { defined $_->{filter} } @{$columns};
  my @search = map { whereFilter($C->{QUOTE}.$source.$C->{QUOTE}.'.'.$C->{QUOTE}.$_->{col}.$C->{QUOTE}, $_->{searchcriteria}, $dbms) } grep { defined $_->{search} } @{$columns};

  my @filter_data =   (map { $_->{filter} } grep { defined $_->{filter} } @{$columns});
  my @filter_search = (map { $_->{search} } grep { defined $_->{search} } @{$columns});

  # TODO: pk columns should be ordered (pk asc)
  my @order_by =      (map { $C->{QUOTE}.$source.$C->{QUOTE}.'.'.$C->{QUOTE}.$_->{col}.$C->{QUOTE}." ".$_->{order} } grep { defined $_->{order}  } @{$columns});
  my @order_by_pk =   (map { $C->{QUOTE}.$source.$C->{QUOTE}.'.'.$C->{QUOTE}.$_->{col}.$C->{QUOTE}." $order" }       grep { defined $_->{pk}     } @{$columns});


  my ($pk_conditions, $pk_conditions_data) = pk_conditions(
    [map { $_->{col} } grep { defined $_->{pk} } @{$columns}],
    $goto->{pk},
    $goto->{move}
  );

  my ($limit1, $limit2) = limitFilter($start, $length, $dbms);

  my $query;
  my $query_search;
  my $query_limit;

  # query

  $query = "SELECT\n";
  $query .= join(",\n", map { '  '.$_ } @sc) . "\n";
  $query .= "FROM\n";
  $query .= sprintf '  '.$C->{QUOTE}.'%s'.$C->{QUOTE}."\n", $source;
  if (defined $pk_conditions) {
    $query .= "WHERE\n  ";
    $query .= join("\n  AND ", grep defined, (@filter, $pk_conditions));
  }

  # query_search

  $query_search = "SELECT\n";
  $query_search .= join(",\n", map { '  '.$_ } @sc) . "\n";
  $query_search .= "FROM\n";
  $query_search .= sprintf '  '.$C->{QUOTE}.'%s'.$C->{QUOTE}."\n", $source;
  if ((@filter) || (defined $pk_conditions) || (@search)) {
    $query_search .= "WHERE\n";
    $query_search .= '  '.join("\n  AND ", grep defined, (@filter, $pk_conditions, @search))."\n";
  }

  # query_limit

  $query_limit = "SELECT\n";
  if ($limit1) {
    $query_limit .= "  $limit1\n";
  }
  $query_limit .= join(",\n", map { '  '.$_ } @sc) . "\n";
  $query_limit .= "FROM\n";
  $query_limit .= sprintf '  '.$C->{QUOTE}.'%s'.$C->{QUOTE}."\n", $source;
  if ((@filter) || (defined $pk_conditions) || (@search)) {
    $query_limit .= "WHERE\n";
    $query_limit .= '  '.join("\n  AND ", grep defined, (@filter, $pk_conditions, @search))."\n";
  }
  if ((@order_by) || (@order_by_pk)) {
    $query_limit .= "ORDER BY\n";
    $query_limit .= '  '.join("\n,  ", @order_by, @order_by_pk)."\n";
  }
  if ($limit2) {
    $query_limit .= "$limit2\n";
  }

  return {
    'query' => $query,
    'query_data' => [@filter_data, @{$pk_conditions_data}],

    'query_search' => $query_search,
    'query_search_data' => [@filter_data, @{$pk_conditions_data}, @filter_search],

    'query_limit' => $query_limit,
    'query_limit_data' => [@filter_data, @{$pk_conditions_data}, @filter_search]
  };
}

sub insertUpdateQuery {
  # TODO: how to distinguish between empty and NULL?
  # TODO: what if a primary key is not auto_increment (or is multiple fields?)
  #       need to distinguish between insert and update, but client side
  my ($source, $columns, $dbms) = @_;

  my $C = $DBMS_MAP->{$dbms};

  # get new columns, and new values
  my @nc = map { $_->{col} } grep { (defined $_->{new}) && (!defined $_->{pk})} @{$columns};
  my @nv = map { $_->{new} } grep { (defined $_->{new}) && (!defined $_->{pk})} @{$columns};

  # get pk columns and pk values (if given)

  my @pkc = map { $_->{col} } grep { (defined $_->{new}) && (defined $_->{pk})} @{$columns};
  my @pkv = map { $_->{new} } grep { (defined $_->{new}) && (defined $_->{pk})} @{$columns};

  my $query;

  if (@pkv) {
    $query  = "UPDATE\n";
    $query .= '  '.$C->{QUOTE}.$source.$C->{QUOTE}."\n";
    $query .= "SET\n";
    $query .= '  '.join(",\n", map { $C->{QUOTE}.$_.$C->{QUOTE}.'=?'} @nc)."\n";
    $query .= "WHERE\n";
    $query .= '  '.join(",\n", map { $C->{QUOTE}.$_.$C->{QUOTE}.'=?'} @pkc)."\n";
  } else {
    $query  = "INSERT INTO\n";
    $query .= '  '.$C->{QUOTE}.$source.$C->{QUOTE}." ";
    $query .= '('.join(',', map { $C->{QUOTE}.$_.$C->{QUOTE} } @nc).")\n";
    $query .= "VALUES\n";
    $query .= '  ('.join(',', (map { '?' } @nc) ).")\n";
  }

  return {
    'query'      => $query,
    'query_data' => [@nv, @pkv],
    'query_type' => (@pkv)?'UPDATE':'INSERT'
  };
}

1;
