package Sentosa::Objects;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

sub get_object {
  # TODO: I decided to ignore type, since a query can became a form, and a form can became a query.
  # TODO: I just want to be sure that it's actually a good idea
  my ($id, $objecttype, $userid) = @_;

  my $ar = $dbh->selectall_arrayref(
    "SELECT o.id, o.name, o.source, o.description, o.def, o.pk, c.db, c.username, c.password
    FROM
      af_objects o LEFT JOIN af_connections c
      ON o.id_connection = c.id
    WHERE
      o.id=?
      AND
        o.id_app IN (
          SELECT a.id
          FROM
            af_apps a LEFT JOIN af_appgroups ag
            ON a.id = ag.id_app
            LEFT JOIN af_usergroups u
            ON ag.id_group = u.id_group
          WHERE
            u.id_user=?
            OR '1'=?
        )
    ",
    {Slice => {}},
    $id,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!

 return @{ $ar };
}

sub get_objectlist {
  # TODO: return only objects per app, add id_app parameter
  my ($userid, $objecttype) = @_;
  my $ar = $dbh->selectall_arrayref(
    "SELECT o.id, o.name, o.source, o.description
    FROM af_objects o
    WHERE
      (o.type=?)
      AND
        o.id_app IN (
          SELECT a.id
          FROM
            af_apps a LEFT JOIN af_appgroups ag
            ON a.id = ag.id_app
            LEFT JOIN af_usergroups u
            ON ag.id_group = u.id_group
          WHERE
            u.id_user=?
            OR '1'=?
        )
    ",
    {Slice => {}},
    $objecttype,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!

  return @{ $ar };
}
