package Sentosa::Objects;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

sub get_object {
  my ($id, $objecttype, $userid) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT o.id, o.name, o.source, o.description
    FROM af_objects o
    WHERE
      o.id=? AND o.type=?
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
    $objecttype,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!

 return $ar;
}