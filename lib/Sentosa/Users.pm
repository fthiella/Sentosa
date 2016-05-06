package Sentosa::Users;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

=head1 NAME

B<Sentosa::Users> - routines for user authentication, and users and groups management
 
=cut

sub get_userinfo {
  my ($id) = @_;
  
  my $ar = $dbh->selectrow_hashref(
    "SELECT id, username, userdesc
    FROM af_users
    WHERE id=?",
    {Slice => {}},
    $id
  );

 return $ar;
}

sub get_userproperty {
  my ($id, $property) = @_;
  
  my $ar = $dbh->selectrow_hashref(
    "SELECT value
    FROM af_userproperties
    WHERE id_user=? and property=?",
    {Slice => {}},
    $id, $property
  );

 return $ar->{value};
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

sub get_appinfo {
  my ($id, $app) = @_;
  
  my $ar = $dbh->selectrow_hashref(
    "SELECT a.id, a.url, a.details, a.cover, a.image
    FROM
      af_apps a LEFT JOIN af_appgroups ag
      ON a.id = ag.id_app
      LEFT JOIN af_usergroups u
      ON ag.id_group = u.id_group
    WHERE
      (u.id_user=? OR '1'=?)
      AND a.url=?",
    {Slice => {}},
    $id,
    $id,
    $app
  );

 return $ar;
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
 
  if (($ar->[0]->{username}) && ($ar->[0]->{username} eq $u)) {
   return $ar->[0]->{id};
  }

 return undef;
}
 
1;
