package Sentosa::Import;
use Poet::Moose;
extends 'Poet::Import';

use DBI;

method provide_var_dbh ($caller) {
  return DBI->connect(
    'dbi:SQLite:dbname=data/sentosa.db',
    '',
    '',
    { RaiseError => 1 },
  ) or die $DBI::errstr;
}

1;
