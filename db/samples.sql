drop table if exists gardens;

create table gardens (
  id integer primary key autoincrement,
  name string,
  city string
);

insert into gardens (id, name, city) values
(1, 'Gardens by the Bay', 'Singapore'),
(2, 'Central Park', 'New York'),
(3, 'Hyde Park', 'London');

create table attractions (
  id integer primary key autoincrement,
  id_garden integer,
  attraction string,
  foreign key (id_garden) references gardens(id)
);

insert into attractions (id_garden, attraction) values
(1, 'Cloud Forest'),
(1, 'Skyway'),
(1, 'Supertree Grove'),

(2, 'Great Lawn'),
(2, 'Wildlife Sanctuary'),

(3, 'Italian Gardens'),
(3, 'The Serpentine'),
(3, 'Speaker''s Corner'),
(3, 'Marble Arch');

create table multiple (
  key1 integer,
  key2 integer,
  key3 integer,
  v string
);

insert into multiple values
(1,2,3, 'first'),
(1,2,4, 'b'),
(1,3,1, 'c'),
(2,1,1, 'd'),
(2,2,1, 'e'),
(2,2,2, 'last');