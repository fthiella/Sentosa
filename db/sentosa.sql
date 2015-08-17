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

-- af_sessions: session management server-side

create table if not exists af_sessions (
 id integer primary key autoincrement,
 auth_user_id integer,
 auth_ts timestamp default CURRENT_TIMESTAMP
);
 
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
  FOREIGN KEY(id_app) REFERENCES af_apps(id),
  FOREIGN KEY(id_connection) REFERENCES af_connections(id)
);

insert into af_objects values
-- management
(1, 1, 'form',  'Users',   1, 'af_users',  'id', 'Users Form'),
(2, 1, 'form',  'Groups',  1, 'af_groups', 'id', 'Groups Form'),
(3, 1, 'query', 'Users',   1, 'af_users',  'id', 'Users List'),
(4, 1, 'query', 'Groups',  1, 'af_groups', 'id', 'Groups List'),
-- sample app
(5, 2, 'form',  'Gardens', 2, 'gardens',   'id', 'Gardens Form'),
(6, 2, 'form',  'Flowers', 2, 'flowers',   'id', 'Flowers Form'),
(7, 2, 'query', 'Gardens', 2, '',          'id', 'Gardens List'),
(8, 2, 'query', 'Flowers', 2, '',          'id', 'Flowers List');

create table af_forms (
  id integer primary key autoincrement,
  id_object integer,
  box varchar(45),
  col varchar(45),
  type varchar(45),
  caption varchar(45),
  foreign key (id_object) references af_objects (id)
);

insert into af_forms values
(1,  1, 'box1', 'id',        'hidden', 'id'),
(2,  1, 'box2', 'username',  'text',   'User Name'),
(3,  1, 'box2', 'password',  'text',   'Password'),

(4,  2, 'box1', 'id',        'hidden', 'id'),
(5,  2, 'box2', 'groupname', 'text',   'Group Name'),

(6,  5, 'box1', 'id',        'hidden', 'id'),
(7,  5, 'box2', 'name',      'text',   'Garden Name'),
(8,  5, 'box2', 'city',      'text',   'City'),

(9,  6, 'box1', 'id',        'hidden', 'id'),
(10, 6, 'box2', 'name',      'text',   'Flower Name');