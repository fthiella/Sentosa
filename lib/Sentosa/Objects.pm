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
  my ($userid, $objecttype, $app) = @_;
  my $ar = $dbh->selectall_arrayref(
    "SELECT o.id, o.name, o.source, o.description, a.url, a.details
    FROM af_objects o INNER JOIN af_apps a ON o.id_app=a.id
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
      AND a.url=?
    ",
    {Slice => {}},
    $objecttype,
    $userid,
    $userid,
    $app
  );
  # TODO: administrators have to see everything!

  return @{ $ar };
}
