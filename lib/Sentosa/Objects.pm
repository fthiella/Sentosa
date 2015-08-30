package Sentosa::Objects;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

sub get_object {
  my ($id, $objecttype, $userid) = @_;

  my $ar = $dbh->selectall_arrayref(
    "SELECT o.id, o.name, o.source, o.description, o.def, o.pk, c.db, c.username, c.password
    FROM
      af_objects o LEFT JOIN af_connections c
      ON o.id_connection = c.id
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

 return @{ $ar };
}

sub get_objectlist {
  my ($userid, $objecttype) = @_;
  my $ar = $dbh->selectall_arrayref(
    "SELECT o.id, o.name, o.source, o.description
    FROM af_objects o
    WHERE
      o.type=?
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

sub get_formboxes {
  my ($id, $userid) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT DISTINCT f.box
     FROM
       af_forms f INNER JOIN af_objects o
       ON f.id_object=o.id
     WHERE
       f.id_object=?
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
     ORDER BY
       f.id
    ",
    {Slice => {}},
    $id,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!

 return @{ $ar };
}

sub get_formelements {
  my ($id, $box, $userid) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT f.id, f.box, f.col, f.type, f.caption, f.params
     FROM
       af_forms f INNER JOIN af_objects o
       ON f.id_object=o.id
     WHERE
       f.id_object=?
       AND
       f.box=?
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
     ORDER BY
       f.id
    ",
    {Slice => {}},
    $id,
    $box,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!

 return @{ $ar };
}

sub get_formcolumns {
  my ($id, $userid) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT f.id_object, f.col
     FROM
       af_forms f INNER JOIN af_objects o
       ON f.id_object=o.id
     WHERE
       f.id_object=?
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
     ORDER BY
       f.id
    ",
    {Slice => {}},
    $id,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!
 return @{ $ar };
}

sub get_formconnection {
  my ($id, $userid) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT c.id, c.db, c.username, c.password, o.source, o.pk
     FROM
       af_forms f INNER JOIN af_objects o
       ON f.id_object=o.id
       INNER JOIN af_connections c
       ON o.id_connection = c.id
     WHERE
       f.id_object=?
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
     ORDER BY
       f.id
    ",
    {Slice => {}},
    $id,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!

 return @{ $ar };
}

sub get_queryconnection {
  my ($id, $userid) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT c.id, c.db, c.username, c.password, o.source, o.pk
     FROM
       af_query q INNER JOIN af_objects o
       ON q.id_object=o.id
       INNER JOIN af_connections c
       ON o.id_connection = c.id
     WHERE
       q.id_object=?
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
     ORDER BY
       q.id_object
    ",
    {Slice => {}},
    $id,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!

 return @{ $ar };
}

sub get_querycolumns {
  my ($id, $userid) = @_;
  
  my $ar = $dbh->selectall_arrayref(
    "SELECT q.id_object, q.col, q.caption, q.link, q.global_search
     FROM
       af_query q INNER JOIN af_objects o
       ON q.id_object=o.id
     WHERE
       q.id_object=?
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
     ORDER BY
       q.id
    ",
    {Slice => {}},
    $id,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!
 return @{ $ar };
}