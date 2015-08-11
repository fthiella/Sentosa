package Sentosa::Utils;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

sub get_info {
  my ($attr) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT attribute, value
    FROM af_info
    WHERE attribute=?",
    {Slice => {}},
    $attr
  );
  
  if ($ar->[0]->{attribute} eq $attr) {
   return $ar->[0]->{value};
  }
  
  return undef;
}

sub get_appinfo {
 return get_info('name').' '.get_info('version');
}

1;