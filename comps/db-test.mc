<%class>
  has '_id';

  has 'iDisplayStart';
  has 'iDisplayLength';
  has 'iColumns';

  has 'sEcho';
</%class>
<%init>
  # TODO: it is fun to code this component, but it's still not rock solid, maybe DBIx::Class could help much more? http://www.dbix-class.org/
  use feature "switch";
  use JSON ();
  use Sentosa::Objects;
  use Sentosa::Db;

  my ($obj) = Sentosa::Objects::get_object($._id, 'query', $m->session->{auth_id});
  if (!$obj) { $m->not_found(); }; # form not found
  
  # array of hashes @{$columns} one hash for each column
  # TODO: why am I using this syntax @{$columns} ?
  my $columns = JSON->new->utf8->decode($obj->{def});
  
  # create a lookup table, it will make things easier later
  my %columns_lookup;
  my $i=0;
  foreach my $c (@{$columns}) {
    $columns_lookup{$c->{col}} = $i++;
  }

  # adds pk info to the columns data structure
  my $i=0;
  foreach my $k (split ',', $obj->{pk}) {
    ${$columns}[ %columns_lookup->{$k} ]{'pk'} = $i++;
  }

  ${$columns}[ 0 ]{filter} = 'filter test';
  ${$columns}[ 1 ]{order} = 'DESC';
  ${$columns}[ 1 ]{pk} = 1;

  foreach (grep {/^sSearch_\d+/} keys $.args) {
    if ($.args->{$_} ne "") {
      # add filter to the column
      /sSearch_(\d+)/;
      ${$columns}[ $1 ]{search} = $.args->{$_};
    }
  }

#  print dh \$columns;

 # my $h = DBI->connect($obj->{db}, $obj->{username}, $obj->{password}) or die("connection to ".$obj->{db}." error.\n");
  my %q = Sentosa::Db::selectQuery(
    $obj->{source},
    $columns,
    'DESC',
    { move => 'forwards', pk => [66,77] },
    $.iDisplayStart,
    $.iDisplayLength,
    'Pg'
  );

  print dh \%q;
</%init>