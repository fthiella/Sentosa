package Sentosa::Objects;
use Poet::Moose;
extends 'Poet::Import';

use Poet qw($dbh);

use JSON ();

sub get_object {
  # TODO: I decided to ignore type, since a query can became a form, and a form can became a query, but I'm still undecided if this is a good idea or not :)
  my $id = shift;
  my $objecttype = shift;
  my $userid = shift // 0;

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

sub get_object_by_name {
  # TODO: I decided to ignore type, since a query can became a form, and a form can became a query, but I'm still undecided if this is a good idea or not :)
  my $idapp = shift;
  my $name = shift;
  my $objecttype = shift;
  my $userid = shift // 0;

  my $ar = $dbh->selectall_arrayref(
    "SELECT o.id, o.name, o.source, o.description, o.def, o.pk, c.db, c.username, c.password
    FROM
      af_objects o INNER JOIN af_apps a ON o.id_app=a.id
      INNER JOIN af_connections c ON o.id_connection = c.id
    WHERE
      a.url=? and o.name=?
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
    $idapp,
    $name,
    $userid,
    $userid
  );
  # TODO: administrators have to see everything!

 return @{ $ar };
}

sub get_objectlist {
  # TODO: return only objects per app, add id_app parameter
  my $userid = shift // 0;
  my $objecttype = shift;
  my $app = shift;

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

sub parse_object {
  my $obj = shift;

  # array of hashes @{$columns} one hash for each column
  my $columns = JSON->new->utf8->decode($obj->{def});
  
  # create a lookup table, it will make things easier later
  my %columns_lookup;
  my $i=0;
  foreach my $c (@{$columns}) {
    $columns_lookup{$c->{col}} = $i++;
  }

  # adds pk info to the columns data structure
  $i=0;
  foreach my $k (split ',', $obj->{pk}) {
    # TODO: deprecated
    ${$columns}[ %columns_lookup->{$k} ]{'pk'} = $i++;
  }

  return $columns;
}

sub get_recordSource {
  my $args = shift;

  #my ($obj) = Sentosa::Objects::get_object($._id, 'query', $m->session->{auth_id});
  #if (!$obj) { $m->not_found(); }; # form not found
  #my ($columns) = Sentosa::Objects::parse_object($obj);

  my ($obj) = Sentosa::Objects::get_object_by_name($args->{app}, $args->{obj}, $args->{type}, $args->{userid});
  if (!$obj) { return; }

  my ($columns) = Sentosa::Objects::parse_object($obj);

  # Add filter from properties

  foreach my $l (@{$columns}) {
    if (defined($l->{filter}) && ($l->{filter} =~ /^\{(.*)\}$/)) {
      $l->{filter}=Sentosa::Users::get_userproperty($args->{userid}, $1);
    };
  }

  return ($obj, $columns);
}

1;
