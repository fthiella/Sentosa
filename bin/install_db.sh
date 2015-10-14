#!/usr/bin/sh

mkdir -p data

if [ -f data/sentosa.db ];
then
  echo "Removing old sentosa.db ..."
  rm data/sentosa.db
fi

echo "Importing sentosa.sql ..."
sqlite3 -batch data/sentosa.db < db/sentosa.sql

if [ -f db/sentosa.custom.sql ];
then
  echo "Importing sentosa.custom.sql ..."
  sqlite3 -batch data/sentosa.db < db/sentosa.custom.sql
fi

if [ -f data/chinook.db ];
then
  echo "Removing old chinook.db ..."
  rm data/chinook.db
fi

echo "Importing chinook.sql ..."
sqlite3 -batch data/chinook.db < db/chinook.sql

echo "Done!"
