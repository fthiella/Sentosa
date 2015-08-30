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
(1, 1, 'form',  'Users',       1, 'af_users',    'id', 'Users Form',
'[
{
  "name": "box1",
  "elements": [{
    "col": "id",
    "params": null,
    "caption": "id",
    "type": "hidden"
  }]
},
{
  "name": "box2",
  "elements": [{
    "col": "username",
    "params": null,
    "caption": "User Name",
    "type": "text"
  },
  {
    "col": "password",
    "params": null,
    "caption": "Password",
    "type": "text"
  }]
}
]'),

(2, 1, 'form',  'Groups',      1, 'af_groups',   'id', 'Groups Form',
'[
{
  "name": "box1",
  "elements": [{
    "col": "id",
    "params": null,
    "caption": "id",
    "type": "hidden"
  }]
},
{
  "name": "box2",
  "elements": [{
    "col": "groupname",
    "params": null,
    "caption": "Group Name",
    "type": "text"
  }]
}
]'),

(3, 1, 'query', 'Users',       1, 'af_users',    'id', 'Users List',  NULL),
(4, 1, 'query', 'Groups',      1, 'af_groups',   'id', 'Groups List', NULL),
-- sample app
(5, 2, 'form',  'Gardens',     2, 'gardens',     'id', 'Gardens Form',
'[
{
  "name": "box1",
  "elements": [{
    "col": "id",
    "params": null,
    "caption": "id",
    "type": "hidden"
  }]
},
{
  "name": "box2",
  "elements": [{
    "col": "name",
    "params": null,
    "caption": "Garden Name",
    "type": "text"
  },
  {
    "col": "city",
    "params": null,
    "caption": "City",
    "type": "text"
  }]
},
{
  "name": "box3",
  "elements": [{
    "col": "8",
    "params": "q.id_garden=f.id",
    "caption": "Attractions",
    "type": "query"
  }]
}
]'),

(6, 2, 'form',  'Attractions', 2, 'attractions', 'id', 'Attractions Form',
'[
{
  "name": "box1",
  "elements": [{
    "col": "id",
    "params": null,
    "caption": "id",
    "type": "hidden"
  }]
},
{
  "name": "box2",
  "elements": [{
    "col": "id_garden",
    "params": null,
    "caption": "id_garden",
    "type": "text"
  },
  {
    "col": "attraction",
    "params": null,
    "caption": "Flower Name",
    "type": "text"
  }]
}
]'),

(7, 2, 'query', 'Gardens',     2, 'gardens',     'id', 'Gardens List', NULL),
(8, 2, 'query', 'Attractions', 2, 'attractions', 'id', 'Attractions List', NULL),

(9, 1, 'form',  'Objects',     1, 'af_objects',  'id', 'Sentosa Objects',
'[
{
  "name": "box1",
  "elements": [{
    "col": "id",
    "params": null,
    "caption": "id",
    "type": "hidden"
  }]
},

{
  "name": "box2",
  "elements": [{
    "col": "id_app",
    "params": null,
    "caption": "Application",
    "type": "text"
  },
  {
    "col": "type",
    "params": null,
    "caption": "Type",
    "type": "text"
  },
  {
    "col": "name",
    "params": null,
    "caption": "Name",
    "type": "text"
  },
  {
    "col": "id_connection",
    "params": null,
    "caption": "Connection",
    "type": "text"
  },
  {
    "col": "source",
    "params": null,
    "caption": "Source",
    "type": "text"
  },
  {
    "col": "pk",
    "params": null,
    "caption": "Primary Key",
    "type": "text"
  }]
},


{
  "name": "box3",
  "elements": [{
    "col": "description",
    "params": null,
    "caption": "Description",
    "type": "text"
  }]
},

{
  "name": "box4",
  "elements": [{
    "col": "def",
    "params": null,
    "caption": "Definition",
    "type": "text"
  }]
}

]'
);

create table af_forms (
  id integer primary key autoincrement,
  id_object integer,
  box varchar(45),
  col varchar(45),
  type varchar(45),
  caption varchar(45),
  params string,
  foreign key (id_object) references af_objects (id)
);

insert into af_forms values
(1,  1, 'box1', 'id',          'hidden', 'id',          NULL),
(2,  1, 'box2', 'username',    'text',   'User Name',   NULL),
(3,  1, 'box2', 'password',    'text',   'Password',    NULL),

(4,  2, 'box1', 'id',          'hidden', 'id',          NULL),
(5,  2, 'box2', 'groupname',   'text',   'Group Name',  NULL),

(6,  5, 'box1', 'id',          'hidden', 'id',          NULL),
(7,  5, 'box2', 'name',        'text',   'Garden Name', NULL),
(8,  5, 'box2', 'city',        'text',   'City',        NULL),
(9,  5, 'box3', '8',           'query',  'Attractions', 'q.id_garden=f.id'),

(10, 6, 'box1', 'id',          'hidden', 'id',          NULL),
(11, 6, 'box2', 'id_garden',   'text',   'id_garden',   NULL),
(12, 6, 'box2', 'attraction',  'text',   'Flower Name', NULL);

create table af_query (
  id integer primary key autoincrement,
  id_object integer,
  col string,
  caption string,
  link string,
  global_search int,
  foreign key(id_object) references af_objects(id)
);

insert into af_query (id_object, col, caption, link, global_search) values
(3, 'id',         'id',         NULL,         0),
(3, 'username',   'User Name',  NULL,         1),
(3, 'password',   'Password',   NULL,         0),

(4, 'id',         'id',         NULL,         0),
(4, 'groupname',  'Group Name', NULL,         1),

(7, 'id',         'id',         NULL,         0),
(7, 'name',       'Name',       NULL,         0),
(7, 'city',       'City',       NULL,         0),

(8, 'id',         'id',         NULL,         0),
(8, 'id_garden',  'id_garden',  'form?_id=5', 0),
(8, 'attraction', 'Attraction', NULL,         0);