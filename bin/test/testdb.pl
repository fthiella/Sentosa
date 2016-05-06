use Sentosa::Db;
use JSON ();

my ($obj) = {
    db => 'dbi:SQLite:dbname=data/sentosa.db',
    def => '[
  {"box": "box1", "col": "id", "params": null, "caption": "id", "type": "hidden", "pk": 0},
  {"box": "box2", "col": "username", "params": null, "caption": "User Name", "type": "text", "pk": 1 },
  {"box": "box2", "col": "password", "params": null, "caption": "Password", "type": "text", "search": "ciao" }
]',
    description => 'Users Form',
    id => 1,
    name => 'Users',
    password => '',
    pk => 'id',
    source => 'af_users',
    username => ''
};

my $columns = JSON->new->utf8->decode($obj->{def});

my $q = Sentosa::Db::selectQuery(
  $obj->{source},
  $columns,
  'ASC',
  { move => 'forwards', pk => [1,2] },
  0,
  10,
  'SQLite'
);

print $q->{query}, "\n";
print $q->{query_search}, "\n";
print $q->{query_limit}, "\n";
