drop table if exists gardens;

create table gardens (
  id integer primary key autoincrement,
  name string,
  city string
);

insert into gardens (name, city) values
('Gardens by the Bay', 'Singapore'),
('Central Park', 'New York'),
('Hyde Park', 'London');

create table flowers (
  id integer primary key autoincrement,
  name string
);
