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

sub selectQuery {
  my ($source, $columns, $start, $length, $dbms) = @_;

  # get all column names from the columns array
  my $sc = join ',', map { $_->{col} } @{$columns}; # TODO: better to use column qualifier

  # Filter: filter table (for example by username)
  # Search: search within filtered table

  # - grep gets all columns that have to be filtered
  # - map creates "field=?" or "fields LIKE ?" etc.

  my $filter = join ' AND ', map {
    whereFilter($_->{col}, $_->{searchcriteria}, $dbms)
  } grep {
    defined $_->{filter}
  } @{$columns};

  my $search = join ' AND ', (
  	(
      map {
        whereFilter($_->{col}, $_->{searchcriteria}, $dbms)
      } grep {
        defined $_->{filter}
      } @{$columns}
    )
    ,
    (
      map {
        whereFilter($_->{col}, $_->{searchcriteria}, $dbms)
      } grep {
          defined $_->{search}
      } @{$columns}
    )
  );

  # create parameters list

  my @filter_data = (
  	map {
      $_->{filter}
    } grep {
      defined $_->{filter}
    } @{$columns}
  );

  my @filter_search = (
  	@filter_data
    ,
    (
    map {
      $_->{search}
    } grep {
      defined $_->{search}
    } @{$columns}
    )
  );

  my ($limit1, $limit2) = limitFilter($start, $length, $dbms);

  return (
    'query' => "SELECT $sc FROM $source". (($filter ne "")?" WHERE $filter":undef),
    'query_data' => \@filter_data,

    'query_search' => "SELECT $sc FROM $source". (($search ne "")?" WHERE $search":undef),
    'query_search_data' => \@filter_search,

    'query_limit' => "SELECT$limit1 $sc FROM $source". (($search ne "")?" WHERE $search":undef)."$limit2",
    'query_limit_data' => \@filter_search
  );
}