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