/*
  conn="dbi:SQLite:dbname=data/sentosa.db"
  username=""
  password=""
*/

/* SENTOSA Application info, version, installation name, etc. */

create table if not exists af_info (
  id integer primary key autoincrement,
  attribute string not null unique,
  value string not null
);

insert or replace into af_info (attribute, value) values
('name', 'Sentosa Autoforms'),
('version', '0.20a');

/* SENTOSA Default users*/

create table if not exists af_users (
  id integer primary key autoincrement,
  username varchar(200) NOT NULL UNIQUE,
  userdesc varchar(200) NOT NULL,
  password varchar(200) NOT NULL
);

insert or replace into af_users (id, username, userdesc, password) values
(1, 'admin', 'Administrator', 'password'),
(2, 'user',  'User',          'password');

/* SENTOSA Default properties for users */

create table if not exists af_userproperties (
	id integer primary key autoincrement,
	id_user integer,
	property varchar(200) NOT NULL,
	value varchar(200) NOT NULL,
	FOREIGN KEY(id_user) REFERENCES af_users(id)
);

insert or replace into af_userproperties (id_user, property, value) values
(1, 'code', 'admin'),
(2, 'code', 'user');

/* SENTOSA Default groups */

create table if not exists af_groups (
  id integer primary key autoincrement,
  groupname string NOT NULL
);

insert or replace into af_groups (id, groupname) values
(1, 'administrators'),
(2, 'samples');

/* SENTOSA Users to groups */

create table if not exists af_usergroups (
  id integer primary key autoincrement,
  id_user integer,
  id_group integer,
  FOREIGN KEY(id_user) REFERENCES af_users(id),
  FOREIGN KEY(id_group) REFERENCES af_groups(id)
);

insert or replace into af_usergroups (id_user, id_group) values
((select id from af_users where username='admin'), (select id from af_groups where groupname='administrators')),
((select id from af_users where username='user'),  (select id from af_groups where groupname='samples'));

/* SENTOSA Standard Apps */

create table if not exists af_apps (
  id integer primary key autoincrement,
  url string unique,
  details string,
  cover string,
  image string
);

insert or replace into af_apps (url, details, cover) values
('admin', 'Sentosa Management', 'Users, groups and applications management.'),
('chinhook', 'Chinook Sample Database', 'The Chinook Sample Database'),
('samples', 'Sentosa Samples', 'Sentosa Sample Database');

/* SENTOSA Standard Apps to Groups */

create table if not exists af_appgroups (
  id integer primary key autoincrement,
  id_app integer,
  id_group integer,
  foreign key(id_app) references af_apps(id),
  foreign key(id_group) references af_groups(id)
);

insert or replace into af_appgroups (id_app, id_group) values
((select id from af_apps where url='admin'),    (select id from af_groups where groupname='administrators')),
((select id from af_apps where url='chinhook'), (select id from af_groups where groupname='samples')),
((select id from af_apps where url='samples'),  (select id from af_groups where groupname='samples'));

/* SENTOSA Standard connections */

create table if not exists af_connections (
  id integer primary key autoincrement,
  name unique,
  db string,
  username string,
  password string
);

insert or replace into af_connections (id, name, db, username, password) values
(1, 'sentosa', 'dbi:SQLite:dbname=data/sentosa.db', '', ''),
(2, 'chinhook', 'dbi:SQLite:dbname=data/chinook.db', '', ''),
(3, 'samples', 'dbi:SQLite:dbname=data/samples.sqlite', '', '');


/* SENTOSA Standard objects */

create table if not exists af_objects (
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
  FOREIGN KEY(id_connection) REFERENCES af_connections(id),
  unique (id_app, name)
);

insert or replace into af_objects values
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
  {"col": "username", "caption": "Username", "filter": "{code}"},
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

(5, 2, 'query', 'Track', 2, 'Track', 'TrackId', 'Track Query',
'[
  {"box": "box1", "col": "TrackId",  "params": null, "caption": "TrackId",    "type": "text"},
  {"box": "box2", "col": "Name",     "params": null, "caption": "Track Name", "type": "text"},
  {"box": "box2", "col": "AlbumId",  "params": null, "caption": "Album",      "type": "text",   "searchcriteria": "=", "link": "form/Album", "link-id": "2"}
]'),

(6, 2, 'form', 'Album', 2, 'Album', 'AlbumId', 'Albums Form',
'[
  {"box": "box1", "col": "AlbumId", "params": null, "caption": "AlbumId", "type": "hidden"},
  {"box": "box2", "col": "Title", "params": null, "caption": "Album Title", "type": "text"},
  {"box": "box2", "col": "ArtistId", "params": null, "caption": "Artist", "type": "select2", "options": {"source": "Artist", "id": "ArtistId", "text": "Name"} },
  {"box": "box3", "query": "Track", "params": "q.AlbumId=f.AlbumId", "caption": "Tracks", "type": "query"}
]'),

(100, 3, 'query', 'Documents', 3, 'documents', 'id', 'User Documents',
'[
  {"box": "box1", "col": "id",   "caption": "ID", "type": "hidden"},
  {"box": "box2", "col": "name", "caption": "Filename", "type": "text", "link": "download/Documents", "link-id": "0"},
  {"box": "box2", "col": "data", "caption": "data", "type": "blob"}
]');