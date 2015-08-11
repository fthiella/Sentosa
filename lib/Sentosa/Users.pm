package Sentosa::Users;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

=head1 NAME

B<Sentosa::Users> - routines for user authentication, and users and groups management
 
=cut

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

sub get_groupsuserinfo {
  my ($id) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT g.id, g.groupname
    FROM
      af_groups g INNER JOIN af_usergroups u
      ON g.id = u.id_group
    WHERE u.id_user=?",
    {Slice => {}},
    $id
  );

 return @{ $ar }; # deference an array reference
}

sub get_appsuserinfo {
  my ($id) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT a.id, a.url, a.details
    FROM
      af_apps a LEFT JOIN af_appgroups ag
      ON a.id = ag.id_app
      LEFT JOIN af_usergroups u
      ON ag.id_group = u.id_group
    WHERE
      u.id_user=?
      OR '1'=?", # admin can access every app
    {Slice => {}},
    $id,
    $id
  );

 return @{ $ar }; # deference an array reference
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
