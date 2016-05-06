use Sentosa::Db;

my $columns = [
  {"col" => "id", "pk" => 0},
  {"col" => "username", "pk" => 1 },
  {"col" => "password", "search" => "ciao" }
];

my $q = Sentosa::Db::selectQuery(
  'a inner join b', #source
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
