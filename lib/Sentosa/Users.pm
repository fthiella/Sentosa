package Sentosa::Users;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

sub get_userinfo {
  my ($id) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT id, username
    FROM af_users
    WHERE id=?",
    {Slice => {}},
    $id
  );
 
  if ($ar->[0]->{id} eq $id) {
   return $ar->[0]->{username};
  }

 return undef;
}

sub auth_user {
  my ($u, $p) = @_;
  my $ar = $dbh->selectall_arrayref(
    "SELECT id, username, password
    FROM af_users
    WHERE username=? AND password=?",
    {Slice => {}},
    $u,
    $p
  );
 
  if ($ar->[0]->{username} eq $u) {
   return $ar->[0]->{id};
  }

 return undef;
}
 
1;
