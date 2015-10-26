-- --------------------------------------------------------
-- Internal tables
-- --------------------------------------------------------

PRAGMA encoding = "UTF-8";

-- af_info: application info, version, etc.
create table if not exists af_info (
  id integer primary key autoincrement,
  attribute string not null,
  value string not null
);

insert into af_info (attribute, value) values
('name', 'Sentosa Autoforms'),
('version', '0.10');
 
-- --------------------------------------------------------
-- Configuration Tables
-- --------------------------------------------------------

-- af_users: usernames and passwords
create table if not exists af_users (
  id integer primary key autoincrement,
  username varchar(200) NOT NULL UNIQUE,
  userdesc varchar(200) NOT NULL,
  password varchar(200) NOT NULL
);

insert into af_users (id, username, userdesc, password) values
(1, 'admin', 'Sentosa Administrator', 'password'),
(2, 'user',  'Standard User',         'password');

-- af_groups: groups
create table if not exists af_groups (
  id integer primary key autoincrement,
  groupname string NOT NULL
);

insert into af_groups (id, groupname) values
(1, 'administrators'),
(2, 'samples');

-- af_usergroups: Users to Groups
create table if not exists af_usergroups (
  id integer primary key autoincrement,
  id_user integer,
  id_group integer,
  FOREIGN KEY(id_user) REFERENCES af_users(id),
  FOREIGN KEY(id_group) REFERENCES af_groups(id)
);

insert into af_usergroups (id_user, id_group) values
(1, 1),
(2, 2);

-- af_apps: published applications

create table if not exists af_apps (
  id integer primary key autoincrement,
  url string,
  details string,
  cover string,
  image string
);

insert into af_apps (id, url, details, cover) values
(1, 'admin', 'Sentosa Management', 'Users, groups and applications management.'),
(2, 'chinhook', 'Chinook Sample Database', 'The Chinook Sample Database');

-- af_appgroups: Applications to Groups
create table if not exists af_appgroups (
  id integer primary key autoincrement,
  id_app integer,
  id_group integer,
  foreign key(id_app) references af_apps(id),
  foreign key(id_group) references af_groups(id)
);

insert into af_appgroups (id_app, id_group) values
(1, 1),
(2, 2);

-- af_connections: Database connections

create table af_connections (
  id integer primary key autoincrement,
  db string,
  username string,
  password string
);

insert into af_connections (id, db, username, password) values
(1, 'dbi:SQLite:dbname=data/sentosa.db', '', ''),
(2, 'dbi:SQLite:dbname=data/chinook.db', '', '');

-- af_objects: object composing an application

create table af_objects (
  id integer primary key autoincrement,
  id_app integer,
  type varchar(45),
  name varchar(45),
  id_connection integer,
  source string,
  pk string,
  description varchar(45),
  def text,
  FOREIGN KEY(id_app) REFERENCES af_apps(id),
  FOREIGN KEY(id_connection) REFERENCES af_connections(id)
);

insert into af_objects values
-- management
(1, 1, 'form', 'Users', 1, 'af_users', 'id', 'Users Form',
'[
  {"box": "box1", "col": "id", "params": null, "caption": "id", "type": "hidden"},
  {"box": "box2", "col": "username", "params": null, "caption": "User Name", "type": "text" },
  {"box": "box2", "col": "password", "params": null, "caption": "Password", "type": "text" }
]'),

(2, 1, 'form', 'Groups', 1, 'af_groups', 'id', 'Groups Form',
'[
  {"box": "box1", "col": "id", "params": null, "caption": "id", "type": "hidden"},
  {"box": "box2", "col": "groupname", "params": null, "caption": "Group Name", "type": "text" }
]'),

(3, 1, 'query', 'Users', 1, 'af_users', 'id', 'Users List',
'[
  {"col": "id", "caption": "id"},
  {"col": "username", "caption": "Username"},
  {"col": "password", "caption": "Password"}
]'),

(4, 1, 'query', 'Groups', 1, 'af_groups', 'id', 'Groups List',
'[
  {"col": "id", "caption": "id"},
  {"col": "groupname", "caption": "Groupname"}
]'),

-- --------------------------
-- Sample Application Chinook
-- --------------------------

--(5, 2, 'form', 'Album', 2, 'Album', 'AlbumId', 'Albums Form',
--'[
--  {"box": "box1", "col": "AlbumId", "params": null, "caption": "AlbumId", "type": "hidden"},
--  {"box": "box2", "col": "Title", "params": null, "caption": "Album Title", "type": "text"},
--  {"box": "box2", "col": "ArtistId", "params": null, "caption": "Artist", "type": "select", "options": [{"id": "1", "option": "Ac/Dc"}, {"id": "2", "option": "Accept"}, {"id": "3", "option": "Aerosmith"}]},
--  {"box": "box3", "query": "6", "params": "q.AlbumId=f.AlbumId", "caption": "Tracks", "type": "query"}
--]'),

(5, 2, 'form', 'Album', 2, 'Album', 'AlbumId', 'Albums Form',
'[
  {"box": "box1", "col": "AlbumId", "params": null, "caption": "AlbumId", "type": "hidden"},
  {"box": "box2", "col": "Title", "params": null, "caption": "Album Title", "type": "text"},
  {"box": "box2", "col": "ArtistId", "params": null, "caption": "Artist", "type": "select2", "options": {"source": "Artist", "id": "ArtistId", "text": "Name"} },
  {"box": "box3", "query": "6", "params": "q.AlbumId=f.AlbumId", "caption": "Tracks", "type": "query"}
]'),

(6, 2, 'query', 'Track', 2, 'Track', 'TrackId', 'Track Query',
'[
  {"box": "box1", "col": "TrackId",  "params": null, "caption": "TrackId",    "type": "hidden"},
  {"box": "box2", "col": "Name",     "params": null, "caption": "Track Name", "type": "text"},
  {"box": "box2", "col": "AlbumId",  "params": null, "caption": "Album",      "type": "hidden",   "searchcriteria": "="}
]');