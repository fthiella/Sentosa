-- --------------------------------------------------------
-- Internal tables
-- --------------------------------------------------------

-- af_info: application info, version, etc.
create table if not exists af_info (
  id integer primary key autoincrement,
  attribute string not null,
  value string not null
);

insert into af_info (attribute, value) values
('name', 'Sentosa AutoForms'),
('version', '0.01');
 
-- --------------------------------------------------------
-- Configuration Tables
-- --------------------------------------------------------

-- af_users: usernames and passwords
create table if not exists af_users (
  id integer primary key autoincrement,
  username varchar(200) NOT NULL,
  password varchar(200) NOT NULL
);

insert into af_users (id, username, password) values
(1, 'admin', 'adminpwd'),
(2, 'user',  'userpwd');

-- af_groups: groups
create table if not exists af_groups (
  id integer primary key autoincrement,
  groupname string NOT NULL
);

insert into af_groups (id, groupname) values
(1, 'administrators'),
(2, 'gardens');

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
  details string
);

insert into af_apps (id, url, details) values
(1, 'admin', 'Sentosa Management'),
(2, 'gardens', 'Gardens and Flowers');

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
(2, 'dbi:SQLite:dbname=data/samples.db', '', '');

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
-- sample app

(5, 2, 'form', 'Gardens', 2, 'gardens', 'id', 'Gardens Form',
'[
  {"box": "box1", "col": "id", "params": null, "caption": "id", "type": "hidden"},
  {"box": "box2", "col": "name", "params": null, "caption": "Garden Name", "type": "text"},
  {"box": "box2", "col": "city", "params": null, "caption": "City", "type": "text"},
  {"box": "box3", "col": "8", "params": "q.id_garden=f.id", "caption": "Attractions", "type": "query"}
]'),

(6, 2, 'form',  'Attractions', 2, 'attractions', 'id', 'Attractions Form',
'[
  {"box": "box1", "col": "id", "params": null, "caption": "id", "type": "hidden"},
  {"box": "box2", "col": "id_garden", "params": null, "caption": "id_garden", "type": "text"},
  {"box": "box2", "col": "attraction", "params": null, "caption": "Flower Name", "type": "text"}
]'),

(7, 2, 'query', 'Gardens',     2, 'gardens',     'id', 'Gardens List',
'[
  {"col": "id", "caption": "id"},
  {"col": "name", "caption": "Name"},
  {"col": "city", "caption": "City"}
]'),

(8, 2, 'query', 'Attractions', 2, 'attractions', 'id', 'Attractions List',
'[
  {"col": "id", "caption": "id"},
  {"col": "id_garden", "caption": "id_garden", "link": "form?_id=5"},
  {"col": "attraction", "caption": "attraction"}
]'),

(9, 1, 'form',  'Objects',     1, 'af_objects',  'id', 'Sentosa Objects',
'[
  {"box": "box1", "col": "id", "params": null, "caption": "id", "type": "hidden"},
  {"box": "box2", "col": "id_app", "params": null, "caption": "Application", "type": "text"},
  {"box": "box2", "col": "type", "params": null, "caption": "Type", "type": "text"},
  {"box": "box2", "col": "name", "params": null, "caption": "Name", "type": "text"},
  {"box": "box2", "col": "id_connection", "params": null, "caption": "Connection", "type": "text"},
  {"box": "box2", "col": "source", "params": null, "caption": "Source", "type": "text"},
  {"box": "box2", "col": "pk", "params": null, "caption": "Primary Key", "type": "text"},
  {"box": "box3", "col": "description", "params": null, "caption": "Description", "type": "text"},
  {"box": "box4", "col": "def", "params": null, "caption": "Definition", "type": "text"}
]'
),

(10, 2, 'form', 'mult', 2, 'multiple', 'key1,key2,key3', 'Multiple keys',
'[
  {"box": "box1", "col": "key1", "params": null, "caption": "key1", "type": "text"},
  {"box": "box1", "col": "key2", "params": null, "caption": "key2", "type": "text"},
  {"box": "box1", "col": "key3", "params": null, "caption": "key3", "type": "text"},
  {"box": "box1", "col": "v", "params": null, "caption": "v", "type": "text"}
]');