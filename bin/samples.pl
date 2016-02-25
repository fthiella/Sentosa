#!/usr/bin/perl

use strict;
use warnings;

use DBI qw(:sql_types);
use File::Slurp;

my $dbh = DBI->connect("dbi:SQLite:dbname=data/samples.sqlite","","");

my $sql = <<'END_SQL';
CREATE TABLE if not exists documents (
  id       INTEGER PRIMARY KEY,
  name     VARCHAR(100),
  data     BLOB
)
END_SQL
 
$dbh->do($sql);

my $id;
my $blob;
my $name;

my $sth = $dbh->prepare("INSERT or replace INTO documents VALUES (?, ?, ?)");

$id = 1;
$name = 'acdc.jpg';
$blob = read_file('db/acdc.jpg');
$sth->execute($id, $name, $blob);

$id = 2;
$name = 'metallica.jpg';
$blob = read_file('db/metallica.jpg');
$sth->execute($id, $name, $blob);