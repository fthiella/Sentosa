create table if not exists af_info (
  id integer primary key autoincrement,
  attribute string not null,
  value string not null
);
 
insert into af_info (attribute, value) values
('name', 'Sentosa AutoForms'),
('version', '0.01');

create table if not exists af_users (
  id integer primary key autoincrement,
  username varchar(200) NOT NULL,
  password varchar(200) NOT NULL
);

insert into af_users (username, password) values
('admin', 'adminpwd'),
('user',  'userpwd');

create table if not exists af_sessions (
 id integer primary key autoincrement,
 auth_user_id integer,
 auth_ts timestamp default CURRENT_TIMESTAMP
);
